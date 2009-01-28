class OAuthTestWrapper
  class Client
    attr_reader :access_token, :request_token, :consumer

    def initialize(options = {})
      raise OAuthTestWrapper::ArgumentError, "OAuth Consumer Key and Secret required" if options[:consumer_key].nil? || options[:consumer_secret].nil?

      @consumer = OAuth::Consumer.new(options[:consumer_key], options[:consumer_secret], {
      	:site => OAuthTestWrapper::API_SERVER,
      	:request_token_path => OAuthTestWrapper::REQUEST_TOKEN_PATH,
      	:access_token_path => OAuthTestWrapper::ACCESS_TOKEN_PATH,
      	:authorize_url => OAuthTestWrapper::AUTHORIZATION_URL,
      	:scheme=>:header,
      	:http_method=>:get
      })

      if options[:request_token] && options[:request_token_secret]
        @request_token = OAuth::RequestToken.new(@consumer, options[:request_token], options[:request_token_secret])
      else
        @request_token = nil
      end

      if options[:access_token] && options[:access_token_secret]
        @access_token = OAuth::AccessToken.new(@consumer, options[:access_token], options[:access_token_secret])
      else
        @access_token = nil
      end
    end
    
    # http://oauth.net/core/1.0#anchor9
    # OAuth Authentication is done in three steps:

    # 1. The Consumer obtains an unauthorized Request Token
    def get_request_token(force_token_regeneration = false)
      if force_token_regeneration || @request_token.nil?
        @request_token = @consumer.get_request_token
      end
      @request_token
    end

    # 2. The User authorizes the Request Token
    def authorize_url
      raise OAuthTestWrapper::ArgumentError, "call #get_request_token first" if @request_token.nil?
      @request_token.authorize_url
    end

    # 3. The Consumer exchanges the Request Token for an Access Token
    def get_access_token
      raise OAuthTestWrapper::ArgumentError, "call #get_request_token and have user authorize the token first" if @request_token.nil?
      @access_token = @request_token.get_access_token
    end
    
    # Now the wrapper goodness...

    # Get messages
    def messages(reload = false)
      raise OAuthTestWrapper::ArgumentError, "OAuth Access Token Required" unless @access_token

      if reload || @messages.nil?
        response = OAuthTestWrapper::Response.new(access_token.get('/messages.json', {'Accept'=>'application/json'}))
      
        @messages = response.data.map do |message|
          OAuthTestWrapper::Message.new(message)
        end
      end
      
      @messages
    end
    
    # Create a message
    def create_message(name, details)
      raise OAuthTestWrapper::ArgumentError, "OAuth Access Token Required" unless @access_token

      message = OAuthTestWrapper::Message.new({'name' => name, 'details' => details})
      
      response = OAuthTestWrapper::Response.new(access_token.post('/messages.json', message.to_json, {'Accept'=>'application/json','Content-Type' => 'application/json'}))
      
      @message = OAuthTestWrapper::Message.new(response.data)
    end

    # Show a message
    def show_message(message_id, reload = false)
      raise OAuthTestWrapper::ArgumentError, "OAuth Access Token Required" unless @access_token

      if reload || @message.nil?
        response = OAuthTestWrapper::Response.new(access_token.get("/message/#{message_id}.json", {'Accept'=>'application/json'}))
      
        @message = OAuthTestWrapper::Message.new(response.data)
      end
      
      @message
    end

  end
end
