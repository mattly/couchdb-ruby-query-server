%w(design view sandbox).each {|mod| require "#{File.dirname(__FILE__)}/couch_db/#{mod}" }
module CouchDB
  extend self
  
  def run(command=[])
    log(command)
    begin
      cmd = command.shift
      case cmd
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
        # log("received unknown directive: [#{command.unshift(cmd).join(',')}]")
        false
      end
    rescue => e
      false
    end
  end
  
  def error(err, msg)
    ["error", err, msg]
  end
  
end