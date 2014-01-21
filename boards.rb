require 'rubygems'
require 'bundler'
Bundler.require

require 'slim/logic_less'

enable :sessions

set :session_secret, 'board secret'
set :slim, :pretty => true

DataMapper::Logger.new($stdout, :debug)
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/boards.db")

h=Builder::XmlMarkup.new(:indent => 2)

class FormModel
  def self.render_form(h, action, inst)
    h.form({action: action}) do
      self.properties.each do |p|
        id= p.name.to_s+"_id"
        h.p do
          case p
          when DataMapper::Property::Text then
            h.label({for: id},p.name.to_s)
            h.textarea({name: p.name, id: id},(inst ? inst.send(p.name) : ""))
          when DataMapper::Property::String then
            h.label({for: id},p.name.to_s)
            h.input ({id: id, type: :text, name: p.name,value: (inst ? inst.send(p.name) : "")})
          end
        end
      end
      h.input({type: :submit, value: "Absenden"})
    end
  end
end


class Card < FormModel
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

  def self.render_index(h)
    boards=Board.all
    h.ul do
      boards.each do |b|
        h.li h.link!(b.title)
      end
    end
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

class <<h
  def link!(url, text)
    a({ href: url },text)
  end
  def header!(t,&block)
    instruct!
    declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    html( "xmlns" => "http://www.w3.org/1999/xhtml") do
      head do
        title t
      end
      body do
        yield
      end
    end
  end
end

get '/views/*' do |v|
  @boards=Board.all
  puts "Boards: ",@boards
  slim v.to_sym
end

post '/boards/create_empty' do
  puts "creating empty board"
  Board.create(:title => "New Board")
end

get '/cards/new' do
  h.header!("Create new Card") do
    Card.render_form(h, "/cards/create", nil)
  end
end
  
get '/cards/create' do
end

# get '/' do
#   session['counter'] ||= 0
#   session['counter'] += 1
#   h.header! ("Boards Main Page") do
#     h.h1 "Boards Overview"
#     if !Board.first() 
#       h.p do |x| 
#         h << "There are no Boards, "
#         h.link!('/boards/create',"create")
#         h << "one!"
#       end          
#     end
#     h.p "another one"
#     h.div ({:id => :counter}) do
#       h.p "hit this page #{session['counter']} times!"
#     end
#   end
# end

get '/' do
  slim :index
end
