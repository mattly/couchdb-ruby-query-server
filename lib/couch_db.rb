%w(design view sandbox).each {|mod| require "#{File.dirname(__FILE__)}/couch_db/#{mod}" }
module CouchDB
  extend self
  
  def run(command=[])
    begin
      case command.shift
      when 'reset'
        View.reset
        true
      when 'ddoc'
        Design.handle(command)
      when 'add_fun'
        View.add_map_function(command.shift)
      when 'map_doc'
        View.map(command.shift)
      when 'reduce'
        View.reduce(command.shift, command.shift)
      when 'rereduce'
        View.rereduce(command.shift, command.shift)
      else
        false
      end
    rescue => e
      # oops
      File.open(File.dirname(__FILE__)+"/../test.log","a") do |f| 
        f << "#{e.message}\n"
        f << e.backtrace.join("\n") + "\n"
      end
      false
    end
  end
  
end