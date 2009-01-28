class OAuthTestWrapper
  class Response
    attr_reader :data
 
    # Parses the JSON response
    def initialize(response)
      case response.code
        when '500'; then raise OAuthTestWrapper::OAuthTestWrapperException, "Internal Server Error"
        when '400'; then raise OAuthTestWrapper::OAuthTestWrapperException, "Method Not Implemented Yet"
      end
      
      @data = JSON.parse(CGI::unescape(response.body))
    end
 
  end
end