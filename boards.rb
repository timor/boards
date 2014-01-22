require 'rubygems'
require 'bundler'
Bundler.require

require 'slim/logic_less'
require 'sinatra/reloader' if development?

enable :sessions

set :session_secret, 'board secret'
set :slim, :pretty => true

# potentially very slow
STDOUT.sync=true

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
  has n, :columns, constraint: :destroy

  def self.create_default(args)
    board=create(args);
    board.columns.create(:title => 'Todo');
    board.columns.create(:title => 'Doing');
    board.columns.create(:title => 'Done');
    board
  end
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

require 'pp'
get '/view/main' do
  bid=session[:current_board]
  if bid
    redirect "/view/board/#{bid}"
  else
    slim "h1 Please select or create a board!"
  end
end

get '/view/*/*' do |resource,vtype|
  puts "view request"
  case resource.to_sym
  when :boards then 
    @boards=Board.all
  when :cards then
    @cards=Card.all
  when :board then
    @board=Board.get(vtype)
    return "board not found" unless @board
    puts "board #{@board.title} with #{@board.columns.length} columns"
    session[:current_board]=vtype
    vtype="view"
  else return 404 end
  slim (resource+"_"+vtype).to_sym
end

post '/boards/create_empty' do
  puts "creating empty board"
  board=Board.create_default(:title => "New Board")
end

post '/delete/board/*' do |id|
  puts "deleting board"
  done=Board.get(id).destroy
  if !done
    puts "board not deleted"
    return [500,["board not deleted"]]
  end
end

post '/boards/*/create_column' do |board_id|
  puts "creating column in board #{board_id}...NOT!"
end

post '/columns/*/create_card' do |col_id|
  puts "creating card in column #{col_id}"
  Column.get(col_id).cards.create(title: "card title", body: "card body")
end

# explicitely disable caching for ajax requests: fuck you IE!
after '/view/*' do
  if request.env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    response["Expires"]="-1"
  end
end

  
get '/' do
  slim :index
end
