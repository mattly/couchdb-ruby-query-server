module CouchDB
  module Design
    class HaltedFunction < StandardError; end

    extend self
    
    DOCUMENTS = {}

    def handle(command=[])
      case cmd = command.shift
      when 'new'
        id, ddoc = command[0], command[1]
        DOCUMENTS[id] = ddoc
        true
      else
        doc = DOCUMENTS[cmd]
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
      ListRenderer.new(func, design_doc).run(head_and_req)
    end
    
    def shows(func, design_doc, doc_and_req)
      response = CouchDB::Runner.new(func, design_doc).run(*doc_and_req.first)
      if response.respond_to?(:first) && response.first == "error"
        response
      else
        response = {"body" => response} if response.is_a?(String)
        ["resp", response]
      end
    end
    
    def updates(func, design_doc, command)
      doc, request = command.shift
      doc.untrust if doc.respond_to?(:untrust)
      if request["method"] == "GET"
        ["error", "method_not_allowed", "Update functions do not allow GET"]
      else
        doc, response = CouchDB::Runner.new(func, design_doc).run(doc, request)
        response = {"body" => response} if response.kind_of?(String)
        ["up", doc, response]  
      end
    end
    
    def validate_doc_update(func, design_doc, command)
      new_doc, old_doc, user_ctx = command.shift
      response = CouchDB::Runner.new(func, design_doc).run(new_doc, old_doc, user_ctx)
      if response.respond_to?(:has_key?) && response.has_key?("forbidden")
        response
      else
        1
      end
    end
    
    class ListRenderer < CouchDB::Runner
      
      def run(head_and_req)
        head, req = head_and_req.first
        @started = false
        @fetched_row = false
        @start_response = {"headers" => {}}
        @chunks = []
        tail = super(head, req)
        get_row if ! @fetched_row
        @chunks.push tail if tail
        ["end", @chunks]
      end
      
      def send(chunk)
        @chunks << chunk
        false
      end
      
      def get_row()
        @fetched_row = true
        __flush_chunks
        if ! @started
          @started = true
        end
        row = CouchDB.read
        case command = row.shift
        when "list_row"
          row.first
        when "list_end"
          false
        else
          throw :fatal, "list_error", "not a row '#{command}'"
        end
      end
      
      def start(response)
        @start_response = response
      end
      
      def __flush_chunks
        response = if @started
          ["chunks", @chunks.dup]
        else
          ["start", @chunks.dup, @start_response]
        end
        CouchDB.write response
        @chunks.clear
      end
      
    end
    
  end
end
