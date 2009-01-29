require 'rubygems'
require 'sinatra'
require 'oauth'
require 'oauth/consumer'
require 'dm-core'
require 'dm-validations'
require 'dm-serializer'
require File.dirname(__FILE__) + '/lib/oauth_test_wrapper'

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/consumer.sqlite3")
 
class Oauth
  include DataMapper::Resource
 
  property :id,         Integer, :serial => true    # primary serial key

  property :consumer_key,     String,  :nullable => false # cannot be null
  property :consumer_secret,  String,  :nullable => false # cannot be null

  property :request_token,    String
  property :request_secret,   String

  property :access_token,    String
  property :access_secret,   String
end

DataMapper.auto_upgrade!

set :views, File.dirname(__FILE__) + '/views_client'

before do
  @client ||= get_client
  
  if !@client.nil?
    if @client.access_token.nil?
      @client = get_access
    end
  end
end

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

get '/messages' do
  if @client.nil?
    erb :consumerkey
  else
    if @client.access_token.nil?
      redirect '/'
    else
      @messages = @client.messages
      erb :list
    end
  end
end

post '/messages' do
  if @client.nil?
    erb :consumerkey
  else
    if @client.access_token.nil?
      redirect '/'
    else
      @message = @client.create_message(params[:message_name], params[:message_details])
      redirect "/messages/#{@message.message_id}"
    end
  end
end

get '/messages/:message_id' do
  if @client.nil?
    erb :consumerkey
  else
    if @client.access_token.nil?
      redirect '/'
    else
      @message = @client.show_message(params[:message_id])
      erb :show
    end
  end
end

post '/addconsumerkey' do
  oauth = Oauth.new
  oauth.consumer_key = params[:consumer_key]
  oauth.consumer_secret = params[:consumer_secret]
  oauth.save
  
  redirect '/messages'
end

private

def get_client
  oauth = Oauth.first
  
  if !oauth.nil?
    clientDetails = {:consumer_key => oauth.consumer_key, :consumer_secret => oauth.consumer_secret}
  
    if oauth.request_token and oauth.request_secret
      clientDetails.merge!({:request_token => oauth.request_token, :request_token_secret => oauth.request_secret})
    end

    if oauth.access_token and oauth.access_secret
      clientDetails.merge!({:access_token => oauth.access_token, :access_token_secret => oauth.access_secret})
    end

    client = OAuthTestWrapper::Client.new(clientDetails)
  end
end

def get_access
  oauth = Oauth.first
  
  if !oauth.access_token or !oauth.access_secret
    
    if !oauth.request_token or !oauth.request_secret
      request_token = @client.get_request_token
      
      oauth.request_token = request_token.token
      oauth.request_secret = request_token.secret
      oauth.save

      redirect @client.authorize_url
    else
      access_token = @client.get_access_token
      
      oauth.access_token = access_token.token
      oauth.access_secret = access_token.secret
      oauth.save
    end
    
  end
  
  @client
end