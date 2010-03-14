module CouchDB
  module View
    extend self
  
    def map_functions
      @functions ||= []
    end
  
    def add_map_function(func)
      #TODO: $SAFE this
      func = eval(func)
      map_functions.push(func)
      true
    end
    
    def reset
      map_functions.clear
    end
  
    def map(doc)
      map_functions.map do |func|
        runner = MapRunner.new
        runner.instance_exec(doc, &func)
        runner.results
      end
    end
  
    class MapRunner
      attr_reader :results
    
      def initialize
        @results = []
      end
    
      def emit(key, value)
        @results.push([key, value])
      end
    end
        
    def reduce(functions, vals)
      ## WHY .FIRST?????? WHY NOT ALL FROM FUNCTIONS????
      func = functions.first
      keys = vals.map {|val| val.shift }
      vals = vals.map {|val| val.shift }
      ret = eval(func).call(keys, vals, false)
      [true, [ret]]
    end
    
    def rereduce(functions, vals)
      func = functions.first
      ret = eval(func).call([], vals, true)
      [true, [ret]]
    end
    
  end
end