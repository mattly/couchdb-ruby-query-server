module CouchDB
  module View
    extend self
  
    def map_functions
      @functions ||= []
    end
  
    def add_map_function(funcstr)
      func = Sandbox.make_proc(funcstr)
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
      keys = vals.map {|val| val.shift }
      vals = vals.map {|val| val.shift }
      result = functions.map do |func|
        Sandbox.make_proc(func).call(keys, vals, false)
      end
      [true, result]
    end
    
    def rereduce(functions, vals)
      result = functions.map do |func|
        Sandbox.make_proc(func).call([], vals, true)
      end
      [true, result]
    end
    
  end
end