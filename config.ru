require 'rubygems'
require 'bundler'

Bundler.require

require './board'
# use Rack::Reloader
run Sinatra::Application
