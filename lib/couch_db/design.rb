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
    
    def lists(func, design_doc, head_and_req)
      ListRenderer.new(func).run(head_and_req)
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
    
    class ListRenderer
      attr_accessor :func
      def initialize(func)
        @func = func
      end
      
      def run(head_and_req)
        head, req = head_and_req.first
        @started = false
        @fetched_row = false
        @start_response = {"headers" => {}}
        @chunks = []
        tail = instance_exec head, req, &func
        get_row if ! @fetched_row
        @chunks.push tail if tail
        ["end", @chunks]
      end
      
      def send(chunk)
        @chunks << chunk
      end
      
      def get_row()
        @fetched_row = true
        __flush_chunks
        if ! @started
          @started = true
        end
        cmd = JSON.parse $stdin.gets
        case cmd.shift
        when "list_row"
          cmd.first
        when "list_end"
          false
        end
      end
      
      def start(response)
        @start_response = response
      end
      
      def __flush_chunks
        response = if @started
          ["chunks", @chunks]
        else
          CouchDB.log @start_response
          ["start", @chunks, @start_response]
        end
        $stdout.puts response.to_json
        $stdout.flush
        @chunks.clear
      end
      
    end
    
  end
end