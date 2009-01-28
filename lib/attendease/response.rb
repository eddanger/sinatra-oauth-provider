class AttendEase
  class Response
 
    #Parses the XML response from AttendEase
    def initialize(doc)
      doc = Hpricot(doc) unless doc.is_a?(Hpricot::Doc || Hpricot::Elem)
      @doc = doc
      #raise AttendEase::AttendEaseException, @doc.at("/rsp/err").attributes["msg"] if !success? 
    end
 
    #does the response indicate success?
    def success?
      #@doc.at("/rsp").attributes["stat"] == "ok" rescue false
    end
 
    #An array of of User-specific tokens and their Location at all levels the Client can see and larger.
    def users
      @users ||= @doc.search("/rsp//user").map do |user|
        AttendEase::User.new(user.to_s)
      end
    end
 
    #A Location array.
    def events
      #@locations ||= @doc.search("/rsp/locations/location").map do |location|
      #  AttendEase::Location.new(location.to_s)
      #end
      @doc
    end
 
  end
end