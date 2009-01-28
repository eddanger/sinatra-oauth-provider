class AttendEase
  class Client
    # TODO add access_token=() and request_token=() methods that check whether the tokens are usable
    
    attr_reader :access_token, :request_token, :consumer, :format

   def initialize(options = {})
      options = {
        :debug  => false,
        :format => AttendEase::FORMAT_XML
      }.merge(options)

      # symbolize keys
      options.map do |k,v|
        options[k.to_sym] = v
      end
      raise AttendEase::ArgumentError, "OAuth Consumer Key and Secret required" if options[:consumer_key].nil? || options[:consumer_secret].nil?
      @consumer = OAuth::Consumer.new(options[:consumer_key], options[:consumer_secret], :site => AttendEase::API_SERVER, :authorize_url => AttendEase::AUTHORIZATION_URL)
      @debug    = options[:debug]
      @format   = options[:format]
      @app_id   = options[:app_id]
      if options[:access_token] && options[:access_token_secret]
        @access_token = OAuth::AccessToken.new(@consumer, options[:access_token], options[:access_token_secret])
      else
        @access_token = nil
      end
      if options[:request_token] && options[:request_token_secret]
        @request_token = OAuth::RequestToken.new(@consumer, options[:request_token], options[:request_token_secret])
      else
        @request_token = nil
      end
    end

    # Obtain an <strong>new</strong> unauthorized OAuth Request token
    def get_request_token(force_token_regeneration = false)
      if force_token_regeneration || @request_token.nil?
        @request_token = consumer.get_request_token
      end
      @request_token
    end

    # Return the Fire Eagle authorization URL for your mobile application. At this URL, the User will be prompted for their request_token.
    def mobile_authorization_url
      raise AttendEase::ArgumentError, ":app_id required" if @app_id.nil?
      "#{AttendEase::MOBILE_AUTH_URL}#{@app_id}"
    end

    # The URL the user must access to authorize this token. get_request_token must be called first. For use by web-based and desktop-based applications.
    def authorization_url
      raise AttendEase::ArgumentError, "call #get_request_token first" if @request_token.nil?
      request_token.authorize_url
    end

    #Exchange an authorized OAuth Request token for an access token. For use by desktop-based and mobile applications.
    def convert_to_access_token
      raise AttendEase::ArgumentError, "call #get_request_token and have user authorize the token first" if @request_token.nil?
      @access_token = request_token.get_access_token
    end



    def events(params)
      raise AttendEase::ArgumentError, "OAuth Access Token Required" unless @access_token
      response = get(AttendEase::EVENTS_API_PATH + ".#{format}", :params => params)
      AttendEase::Response.new(response.body)
    end

 
  protected

    def get(url, options = {}) #:nodoc:
      request(:get, url, options)
    end

    def post(url, options = {}) #:nodoc:
      request(:post, url, options)
    end

    def request(method, url, options) #:nodoc:
      response = case method
      when :post
        access_token.request(:post, url, options[:params])
      when :get
        qs = options[:params].collect { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&") if options[:params]
        access_token.request(:get, "#{url}?#{qs}")
      else
        raise ArgumentError, "method #{method} not supported"
      end

      case response.code
      when '500'; then raise AttendEase::AttendEaseException, "Internal Server Error"
      when '400'; then raise AttendEase::AttendEaseException, "Method Not Implemented Yet"
      else response
      end
    end
  end
end
