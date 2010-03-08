module CouchDB
  class Map
    def self.functions
      @functions ||= []
    end
    
    def self.add_function(func)
      #TODO: $SAFE this
      func = <<-FUNC
        CouchDB.log("evaling func")
        #{func}
      FUNC
      func = eval(func)
      functions.push(func)
      true
    end
    
    def initialize(doc)
      @doc = doc
    end
    
    def run
      self.class.functions.map do |func|
        @map_results = []
        instance_exec(@doc, &func)
        @map_results
      end
    end
    
    def emit(key, value)
      @map_results ||=[]
      @map_results.push([key, value])
    end
  end
end