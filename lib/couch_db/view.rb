module CouchDB
  module View
    extend self
  
    def map_functions
      @functions ||= []
    end
  
    def add_map_function(funcstr)
      response = Sandbox.make_proc(funcstr)
      if response.is_a?(Proc)
        map_functions.push(response)
        true
      else
        response
      end
    end
    
    def reset
      map_functions.clear
    end
  
    def map(doc)
      map_functions.map do |func|
        MapRunner.new(func).run(doc)
        # runner = MapRunner.new
        # runner.instance_exec(doc, &func)
        # runner.results
      end
    end
  
    class MapRunner < CouchDB::Runner
      attr_reader :results
    
      def initialize(*args)
        @results = []
        super(*args)
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
