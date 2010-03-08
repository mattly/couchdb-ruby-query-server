%w(design map).each {|mod| require "#{File.dirname(__FILE__)}/couch_db/#{mod}" }
module CouchDB
  extend self
  
  def run(command=[])
    begin
      case command.shift
      when 'reset'
        Map.functions.clear
        true
      when 'ddoc'
        Design.handle(command)
      when 'add_fun'
        Map.add_function(command.shift)
      when 'map_doc'
        Map.run(command.shift)
      when 'reduce'
        func = command.shift.first
        vals = command.shift
        keys = vals.map {|val| val.shift }
        vals = vals.map {|val| val.shift }
        [true, [eval(func).call(keys, vals, false)]]
      when 'rereduce'
        [true, [eval(command.shift.first).call([], command.shift, true)]]
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