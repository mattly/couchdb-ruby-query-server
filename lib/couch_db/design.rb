module CouchDB
  module Design
    extend self
    
    def documents
      @design_documents ||= {}
    end
    
    def handle(command=[])
      case cmd = command.shift
      when 'new'
        id, ddoc = command[0], command[1]
        documents[id] = ddoc
        true
      else
        doc = documents[cmd]
        action, name = command.shift
        func = name ? doc[action][name] : doc[action]
        func = Sandbox.make_proc(func)
        send action, func, doc, command
      end
    end
    
    def filters(func, design_doc, docs_and_req)
      docs, req = docs_and_req.first
      results = docs.map{|doc| !! func.call(doc, req) }
      [true, results]
    end
    
    def shows(func, design_doc, doc_and_req)
      runner = Runner.new(func)
      begin
        response = runner.run(doc_and_req.first)
        response = {"body" => response} if response.is_a?(String)
        ["resp", response]
      rescue Runner::HaltedFunction
        runner.error
      end
    end
    
    def updates(func, design_doc, command)
      doc, request = command.shift
      doc.untrust if doc.respond_to?(:untrust)
      if request["method"] == "GET"
        ["error", "method_not_allowed", "Update functions do not allow GET"]
      else
        doc, response = func.call(doc, request)
        response = {"body" => response} if response.kind_of?(String)
        ["up", doc, response]  
      end
    end
    
    def validate_doc_update(func, design_doc, command)
      new_doc, old_doc, user_ctx = command.shift
      runner = Runner.new(func)
      begin
        runner.run([new_doc, old_doc, user_ctx])
        1
      rescue Runner::HaltedFunction
        runner.error
      end
    end
    
    class Runner
      class HaltedFunction < StandardError; end
      
      attr_accessor :error, :func
      
      def initialize(func)
        @func = func
      end
      
      def run(args)
        instance_exec *args, &func
      end
      
      def throw(err, *message)
        @error = if err == :error
          ["error", message].flatten
        else
          {err.to_s => message.join(', ')}
        end
        raise HaltedFunction
      end
    end
    
  end
end