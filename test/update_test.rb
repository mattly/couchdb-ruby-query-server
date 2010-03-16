require File.dirname(__FILE__) + '/test_helper'

context "document update functions" do
  setup do
    @func = "lambda{|doc, req| doc['updated'] = true; [doc, 'OK'] }"
    CouchDB.run(["ddoc", "new", "foo", {"updates" => {"bar" => @func}}])
    @doc = {"foo" => "bar"}
  end
  
  def run_update(opts={})
    opts[:fun] ||= "bar"
    opts[:doc] ||= @doc
    opts[:method] ||= "POST"
    CouchDB.run(["ddoc", "foo", ["updates", opts[:fun]], [opts[:doc], {'method' => opts[:method]}]])
  end
  
  test "it returns a status, doc, and body response" do
    assert_equal ["up", @doc.update('updated' => true), {'body' => 'OK'}], run_update
  end
  
  # pending until i go back and add tests to the official view query server test
  #   ok, added a test to the view query server, passes in javascript fails in erlang. #wtf
  # test "it disallows GET requests" do
  #   expected = ["error", "method_not_allowed", "Update functions do not allow GET"]
  #   assert_equal expected, run_update(:method => "GET")
  # end
  
end