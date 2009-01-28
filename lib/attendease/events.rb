#Describes a location
class AttendEase
  class Events

    #Initialize a Location from an XML response
    def initialize(doc)
      doc = Hpricot(doc) unless doc.is_a?(Hpricot::Doc || Hpricot::Elem)
      @doc = doc
    end

    def title
      @title ||= @doc.at("/event/title").innerText rescue nil
    end

  end
end