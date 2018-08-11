#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

require 'resque/server'
require 'resque/scheduler/server'
require 'resque-job-stats/server'

url_map = {
  '/' => Padrino.application
}

resque_web_path = Observatory::Config::Resque::WEB_PATH
url_map[resque_web_path] = Resque::Server.new if resque_web_path

if Observatory::Config::Sentry.enabled?
  use Raven::Rack
end

run Rack::URLMap.new(url_map)
