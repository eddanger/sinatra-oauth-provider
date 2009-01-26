require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-serializer'
require 'oauth/request_proxy/rack_request'
require File.dirname(__FILE__) + '/lib/oauth_provider'

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/test.sqlite3")
 
class Message
  include DataMapper::Resource
 
  property :id,         Integer, :serial => true    # primary serial key
  property :name,       String,  :nullable => false # cannot be null
  property :details,    Text,    :nullable => false # cannot be null
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!

provider = OAuthProvider::create(:sqlite3, 'test.sqlite3')
#provider = OAuthProvider::create(:data_mapper, 'test.sqlite3')


error do
  exception = request.env['sinatra.error']
  warn "%s: %s" % [exception.class, exception.message]
  warn exception.backtrace.join("\n")

  @error = "Oh my! Something went awry. (" + exception.message + ")"
  erb :error
end


# OAuth routes
get "/oauth/request_token" do
  provider.issue_request(request).query_string
end

get "/oauth/access_token" do
  if access_token = provider.upgrade_request(request)
    access_token.query_string
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

# Authorize endpoints
get "/oauth/authorize" do
  if @request_token = provider.backend.find_user_request(params[:oauth_token])
    erb :authorize
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

post "/oauth/authorize" do
  if request_token = provider.backend.find_user_request(params[:oauth_token])
    if request_token.authorize
      #redirect request_token.callback
      halt "Callback would have gone to: " + request_token.callback
    else
      raise "Could not authorize"
    end
  else
    raise Sinatra::NotFound, "No such request token"
  end
end

get "/oauth/applications" do
  erb :applications
end

post '/oauth/applications' do
  begin
    @token = OAuthProvider::Token.generate
    provider.add_consumer(params[:application_callback], @token)
  rescue Exception
    halt "Failed to create a token!"
  end
  
  #redirect "/oauth/applications"
  @shared_key = @token.shared_key
  @secret_key = @token.secret_key
  
  erb :applications
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







mime :json, "application/json"

get '/:model.json' do
  oauth_confirm_access(provider, request)
  
  "#{params[:model]}".singularize.camelize.to_class.all.to_json
end

get '/:model/:id.json' do
  oauth_confirm_access(provider, request)

	"#{params[:model]}".singularize.camelize.to_class.get(params[:id]).to_json
end

post '/:model.json' do
  oauth_confirm_access(provider, request)

	name = params[:model].singularize
	record = name.camelize.to_class.new(JSON.parse(request.body.string)[name])
	record.save
	record.to_json
end

put '/:model/:id.json' do
  oauth_confirm_access(provider, request)

	name = params[:model].singularize
	record = name.camelize.to_class.get(params[:id])
	record.update_attributes(JSON.parse(request.body.string)[name])
	record.to_json
end

delete '/:model/:id.json' do
  oauth_confirm_access(provider, request)

	record = "#{params[:model]}".singularize.camelize.to_class.get(params[:id])
	result = record.to_json
	record.destroy
	result
end

private

def oauth_confirm_access(provider, request)
  begin
    access = provider.confirm_access(request)
  rescue Exception
    halt "No access! Please verify your OAuth access token and secret."
  end
end

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

