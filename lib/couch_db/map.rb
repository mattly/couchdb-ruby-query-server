module CouchDB
  module Map
    extend self
    
    def functions
      @functions ||= []
    end
    
    def add_function(func)
      #TODO: $SAFE this
      func = eval(func)
      functions.push(func)
      true
    end
    
    def run(doc)
      functions.map do |func|
        runner = Runner.new
        runner.instance_exec(doc, &func)
        runner.map_results
      end
    end
    
    class Runner
      attr_reader :map_results
      
      def initialize
        @map_results = []
      end
      
      def emit(key, value)
        @map_results.push([key, value])
      end
    end
  end
end