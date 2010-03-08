module CouchDB
  class Design
    
    def self.documents
      @design_documents ||= {}
    end
    
    def self.handle(command=[])
      case cmd = command.shift
      when 'new'
        id, ddoc = command[0], command[1]
        documents[id] = ddoc
      else
      end
    end
    
  end
end