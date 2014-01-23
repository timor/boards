require 'rubygems'
require 'bundler'
Bundler.require

require 'slim/logic_less'
require 'sinatra/reloader' if development?

enable :sessions

set :session_secret, 'board secret'
set :slim, :pretty => true

# potentially very slow
# STDOUT.sync=true

DataMapper::Logger.new($stdout, :debug)
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/boards.db")

h=Builder::XmlMarkup.new(:indent => 2)

class Card
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :body, Text
  belongs_to :column, :required => false

  timestamps :at
  
  after :save do
    column.touch if column
  end
end

class Column
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :pos, Integer
  property :new_cards_allowed, Boolean, :default => false

  has n, :cards, :constraint => :destroy
  belongs_to :board
  timestamps :at

  after :save do
    board.touch
  end
end

class Board
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  has n, :columns, constraint: :destroy
  timestamps :at
  
  def self.create_default(args)
    board=create(args);
    board.columns.create(:title => 'Todo', :new_cards_allowed => true);
    board.columns.create(:title => 'Doing');
    board.columns.create(:title => 'Done');
    board
  end
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
    session[:current_board]=vtype
    # last_modified(@board.updated_at)
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

# get '/move_over' do
#   b=Board.first
#   b.columns[2].cards.push b.columns[0].cards.pop
#   b.save
#   ""
# end

post '/columns/*/create_card' do |col_id|
  puts "creating card in column #{col_id}"
  Column.get(col_id).cards.create(title: "card title", body: "card body")
end

# explicitely disable caching for ajax requests: fuck you IE!
# after '/view/*' do
#   if request.env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
#     response["Expires"]="-1"
#   end
# end

  
get '/' do
  slim :index
end
