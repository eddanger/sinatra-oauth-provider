# A Message
class OAuthTestWrapper
  class Message
    attr_accessor :message_id, :name, :details, :created_at, :updated_at

    def initialize(message)
      @message_id = message['id']
      @name = message['name']
      @details = message['details']
      @created_at = message['created_at']
      @updated_at = message['updated_at']
    end
    
    def to_json
      {
        'message' => {
          'name' => @name,
          'details' => @details,
        }
      }.to_json
    end

    def save(access_token)
      raise OAuthTestWrapper::OAuthTestWrapperException, "Missing message id" unless @message_id
      
      raise OAuthTestWrapper::ArgumentError, "OAuth Access Token Required" unless access_token
    
      response = OAuthTestWrapper::Response.new(access_token.put("/message/#{@message_id}.json", self.to_json, {'Accept'=>'application/json','Content-Type' => 'application/json'}))
    
      initialize(response.data)
    end

    def delete(access_token)
      raise OAuthTestWrapper::OAuthTestWrapperException, "Missing message id" unless @message_id
      
      raise OAuthTestWrapper::ArgumentError, "OAuth Access Token Required" unless access_token
    
      response = OAuthTestWrapper::Response.new(access_token.delete("/message/#{@message_id}.json", {'Accept'=>'application/json','Content-Type' => 'application/json'}))
    
      response.data
    end
  end

end