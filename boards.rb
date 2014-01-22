require 'rubygems'
require 'bundler'
Bundler.require

require 'slim/logic_less'
require 'sinatra/reloader' if development?

enable :sessions

set :session_secret, 'board secret'
set :slim, :pretty => true

DataMapper::Logger.new($stdout, :debug)
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/boards.db")

h=Builder::XmlMarkup.new(:indent => 2)


class Card
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :body, Text
  property :created_at, DateTime
  property :modified_at, DateTime
end

class Board
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :created_at, DateTime
  has n, :columns
end

class Column
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :pos, Integer
  has n, :cards
  belongs_to :board
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/view/*/*' do |resource,vtype|
  case resource.to_sym
  when :boards then 
    @boards=Board.all
  when :cards then
    @cards=Card.all
  else return 404 end
  slim (resource+"_"+vtype).to_sym
end

post '/boards/create_empty' do
  puts "creating empty board"
  Board.create(:title => "New Board")
end

post '/delete/board/*' do |id|
  board=Board.get(id)
  board.destroy if board
end

post '/boards/*/create_column' do
end
  
get '/' do
  slim :index
end
