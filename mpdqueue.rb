#!/usr/bin/env ruby
# coding: utf-8
#
# today's motto: as simple as possible

require 'yaml'

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
rescue StandardError => e
  STDERR.puts 'Error loading config file'
  STDERR.puts e.to_s
  exit(2)
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
  end

  get '/ajax/current' do
    song = mpd.playing? ? mpd.current_song : nil
    mode = mpd.random? ? :random : :normal
    haml :current, partial: true, locals: {song: song, mode: mode}
  end

  get '/ajax/playlist' do
    song = mpd.playing? ? mpd.current_song : nil
    haml :playlist, partial: true, locals: {current: song, playlist: mpd.queue}
  end

  get '/' do
    haml :front, locals: {config: $config}
  end

  register Sinatra::RocketIO
  io = Sinatra::RocketIO
  io_ready = false
  io.once(:start) { io_ready = true }
  notify = lambda {|event| io.push(event, nil) if io_ready }

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
