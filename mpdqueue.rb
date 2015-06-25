#!/usr/bin/env ruby
# coding: utf-8
#
# today's motto: as simple as possible

require 'yaml'

require 'ruby-mpd'
require 'sinatra/base'
#require 'sinatra/rocketio'
require 'haml'

#require 'pp'

class MPDQueue < Sinatra::Base
  configure do
    enable :static
    enable :logging
    enable :dump_errors
    enable :raise_errors

    set :root, File.dirname(__FILE__)
    set :views, settings.root
    set :public_dir, File.join(settings.root, 'static')
    set :haml, ugly: true
  end

  helpers do
    def mpd
      settings.mpd
    end

    def current
      return nil unless mpd.playing?
      mpd.current_song
    end

    def queue
      queue = mpd.queue
      return nil unless queue && queue.any?
      haml :queue, partial: true, locals: {current: current, queue: mpd.queue}
    end

    def time_to_str(sec)
      if sec > 3600
        Time.at(sec).utc.strftime("%H:%M:%S")
      else
        Time.at(sec).utc.strftime("%M:%S")
      end
    end
  end

  get '/' do
    haml :front, locals: {cfg: settings.config, current: current, queue: queue}
  end
end

STDOUT.sync = STDERR.sync = true

if ARGV.length != 1
  STDERR.puts "Usage: #{$PROGRAM_NAME} config.yaml"
  exit(1)
end

begin
  config = File.open(ARGV.first) {|f| YAML.load(f.read) }
rescue StandardError => e
  STDERR.puts 'Error loading config file'
  STDERR.puts e.to_s
  exit(2)
end

puts 'Connecting to MPD...'
mpd = MPD.new(config[:mpd_host], config[:mpd_port])
mpd.connect
unless mpd.connected?
  STDERR puts 'Error connecting to mpd'
  exit(3)
end
config[:mpd] = mpd

puts 'Starting web backend...'
MPDQueue.set :config, config
MPDQueue.run!(config)
