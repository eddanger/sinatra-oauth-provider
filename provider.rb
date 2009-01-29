require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-serializer'
require File.dirname(__FILE__) + '/lib/rack_oauth_provider'

# a list of oauth protected paths
paths = {
  Regexp.new('\/messages.json') => [:get, :post],
  Regexp.new('\/messages\/[0-9]+.json') => [:get, :put, :delete],
}

use RackOAuthProvider, paths do
end

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/provider.sqlite3")
 
class Message
  include DataMapper::Resource
 
  property :id,         Integer, :serial => true    # primary serial key
  property :name,       String,  :nullable => false # cannot be null
  property :details,    Text,    :nullable => false # cannot be null

  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!

set :views, File.dirname(__FILE__) + '/views'

error do
  exception = request.env['sinatra.error']
  warn "%s: %s" % [exception.class, exception.message]
  warn exception.backtrace.join("\n")

  @error = "Oh my! Something went awry. (" + exception.message + ")"
  erb :error
end

# index!
get '/' do
  erb :index
end

# list
get '/messages' do
  @messages = Message.all
  erb :list
end

# create
post '/messages' do
  @message = Message.new(:name => params[:message_name], :details => params[:message_details])
  if @message.save
    redirect "/messages/#{@message.id}"
  else
    redirect '/messages'
  end
end
 
# show
get '/messages/:id' do
  @message = Message.get(params[:id])
  if @message
    erb :show
  else
    redirect '/messages'
  end
end

get '/:model.json' do
  "#{params[:model]}".singularize.camelize.to_class.all.to_json
end

post '/:model.json' do
	name = params[:model].singularize
	record = name.camelize.to_class.new(JSON.parse(CGI::unescape(request.body.string))[name])
	record.save
	record.to_json
end

get '/:model/:id.json' do
	"#{params[:model]}".singularize.camelize.to_class.get(params[:id]).to_json
end

put '/:model/:id.json' do
	name = params[:model].singularize
	record = name.camelize.to_class.get(params[:id])
	record.update_attributes(JSON.parse(request.body.string)[name])
	record.to_json
end

delete '/:model/:id.json' do
	record = "#{params[:model]}".singularize.camelize.to_class.get(params[:id])
	result = record.to_json
	record.destroy
	result
end

private

class String
  def to_class
    Kernel.const_get(self)
  end

  # http://rails.rubyonrails.org/classes/Inflector.html#M001629
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      self.first + camelize(self)[1..-1]
    end
  end

end

