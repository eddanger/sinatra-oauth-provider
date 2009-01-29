require 'sinatra/base'
require 'oauth/request_proxy/rack_request'
require File.dirname(__FILE__) + '/oauth_provider/lib/oauth_provider'

class RackOAuthProvider < Sinatra::Base
  
  def initialize(app, paths)
    @paths = paths
    @app = app
  end
  
  set :root, File.dirname(__FILE__)
  set :views, File.dirname(__FILE__) + '/rack_oauth_provider'

  provider = OAuthProvider::create(:sqlite3, 'provider.sqlite3')
  #provider = OAuthProvider::create(:data_mapper, 'provider.sqlite3')

  mime :json, "application/json"
  
  # http://blog.joncrosby.me/post/72451217/a-world-of-middleware
  # this hackeration is required for sinatra to be a nice rack citizen
  error 404 do
     @app.call(env)
  end
  
  before do
    # check protected path agaist request path
    # see if we should proceed with oauth access confirmation...
    path = @request.path_info
    
    @paths.each do |protected_oauth_path,protected_oauth_method|
      if protected_oauth_path.match(path)

        if protected_oauth_method.include?(@request.request_method.to_s.downcase.to_sym)
          warn path + " was matched to " + @request.request_method.to_s + " " + protected_oauth_path.to_s
          
          oauth_confirm_access(provider)
        end
      end
    end
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
        redirect request_token.callback
      else
        raise "Could not authorize"
      end
    else
      raise Sinatra::NotFound, "No such request token"
    end
  end

  get "/oauth/applications" do
    @consumers = provider.consumers
    erb :applications
  end

  post '/oauth/applications' do
    begin
      @consumer = provider.add_consumer(params[:application_callback])

      #redirect "/oauth/applications"
      @consumer_key = @consumer.token.shared_key
      @consumer_secret = @consumer.token.secret_key

    rescue Exception
      @error = "Failed to create a token!"
    end

    @consumers = provider.consumers

    erb :applications
  end

  private

  def oauth_confirm_access(provider)
    begin
      access = provider.confirm_access(@request)
    rescue Exception
      halt "No access! Please verify your OAuth access token and secret."
    end
  end


end
  
