#!/usr/bin/env ruby
# coding: utf-8
#
# today was long time ago

require 'open-uri'
require 'uri'
require 'yaml'

require 'json'
require 'sinatra/base'
require 'sinatra/rocketio'
require 'tilt/haml'
require 'ruby-mpd'

# fix Sinatra logging retardation
class String
  def join(*_); self; end
end

STDOUT.sync = STDERR.sync = true

if ARGV.length != 1
  STDERR.puts "Usage: #{$PROGRAM_NAME} config.yaml"
  exit(1)
end

begin
  $config = File.open(ARGV.first) {|f| YAML.load(f.read) }
  $ver = $config[:version] || `git describe --tags --always --dirty`
rescue StandardError => e
  STDERR.puts 'Error loading config file'
  STDERR.puts e.to_s
  exit(2)
end

$counter = 0

module AlbumArt
  @@mtx = Mutex.new
  @@last = [nil, nil]

  def self.get(song)
    term = "#{song.artist} #{song.title}"
    @@mtx.synchronize do
      if @@last.first != term
        img = nil
        begin
          raw = open('https://itunes.apple.com/search?term=' \
                     + URI.encode(term) + '&limit=1&entity=song').read
          data = JSON.parse(raw)
          if data['resultCount'] > 0
            img = data['results'].first['artworkUrl100']
            img = nil if img.nil? || img.empty?
          end
        rescue StandardError => e
          STDERR.puts "Error finding album art: #{e.to_s}"
          STDERR.puts e.backtrace.join("\n")
        ensure
          @@last = [term, img]
        end
      end
      @@last[1]
    end
  end
end

class MPDQueue < Sinatra::Base
  configure do
    enable :static
    enable :logging
    enable :dump_errors
    enable :raise_errors

    set :bind, $config[:host]
    set :port, $config[:port]
    set :root, File.dirname(__FILE__)
    set :views, File.join(settings.root, 'views')
    set :public_dir, File.join(settings.root, 'public')
    set :haml, ugly: true
    set :cometio, timeout: 120, post_interval: 2, allow_crossdomain: true
    set :websocketio, port: $config[:io_port]
    set :rocketio, websocket: true, comet: true
  end

  helpers do
    def mpd; settings.mpd; end

    def time_to_str(sec)
      if sec > 3600
        Time.at(sec).utc.strftime("%H:%M:%S")
      else
        Time.at(sec).utc.strftime("%M:%S")
      end
    end

    def shop_link(song)
      return nil unless $config[:shop_link]
      $config[:shop_link] % [URI.encode("#{song.artist} #{song.album}")]
    end

    def render_current
      song = mpd.playing? ? mpd.current_song : nil
      mode = mpd.random? ? :random : :normal
      album_art = $config[:album_art] && song ? AlbumArt.get(song) : nil
      elapsed = song ? mpd.status[:time].first : 0
      haml :current, partial: true, locals: {song: song, elapsed: elapsed, mode: mode,
                                             album_art: album_art}
    end

    def render_playlist
      song = mpd.playing? ? mpd.current_song : nil
      haml :playlist, partial: true, locals: {current: song, playlist: mpd.queue}
    end
  end

  get '/ajax/current' do
    render_current
  end

  get '/ajax/playlist' do
    render_playlist
  end

  get '/' do
    haml :front, locals: {config: $config, ver: $ver}
  end

  register Sinatra::RocketIO
  io = Sinatra::RocketIO
  io_ready = false
  io.once(:start) { io_ready = true }
  notify = lambda {|event, data = nil| io.push(event, data) if io_ready }
  if $config[:counter]
    io.on(:connect)     { $counter += 1; notify.call(:counter, $counter) }
    io.on(:disconnect)  { $counter -= 1; notify.call(:counter, $counter) }
  end

  mpd = MPD.new($config[:mpd_host], $config[:mpd_port], callbacks: true)
  mpd.on(:state)    { notify.call(:current) }
  mpd.on(:song)     { notify.call(:current) }
  mpd.on(:playlist) { notify.call(:playlist) }
  mpd.on(:random)   { notify.call(:current) }
  mpd.connect
  unless mpd.connected?
    STDERR puts 'Error connecting to mpd'
    exit(3)
  end
  set :mpd, mpd
end

MPDQueue.run!
