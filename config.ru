require 'rubygems'
require 'bundler'

Bundler.require

require './boards'
# use Rack::Reloader
run Sinatra::Application
