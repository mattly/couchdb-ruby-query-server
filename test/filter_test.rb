require File.dirname(__FILE__) + '/test_helper'

context "filter functions for change updates" do
  setup do
    @basic = "lambda{|doc, req| doc['good'] == true}"
    CouchDB.run(["ddoc", "new", "foo", {"filters" => {"basic" => @basic}}])
  end
  
  def run_filter(opts={})
    opts[:docs] ||= []
    opts[:req]  ||= {}
    CouchDB.run(["ddoc", "foo", ["filters", "basic"], [opts[:docs]], opts[:req]])
  end
  
  test "filters update by doc contents" do
    docs = (1..3).map do |i|
      {"good" => i.odd? }
    end
    results = run_filter({:docs => docs})
    assert_equal [true, [true, false, true]], results
  end
end
