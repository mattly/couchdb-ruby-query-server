require File.dirname(__FILE__) + '/test_helper'

context "Ruby CouchDB View Server" do
  
  setup do
    CouchDB.run(["reset"])
  end
  
  context "map functions" do
    setup do
      CouchDB::Map.functions.clear
    end
    
    test "runs map functions" do
      CouchDB.run ["add_fun", "lambda{|doc| emit('foo', doc['a']); emit('bar', doc['a'])}"]
      CouchDB.run ["add_fun", "lambda{|doc| emit('baz', doc['a'])}"]
      response = CouchDB.run(["map_doc", {"a" => "b"}])
      expected = [
        [ ["foo", "b"], ["bar", "b"] ],
        [ ["baz", "b"] ]
      ]
      assert_equal expected, response
    end
  end
  
  context "reduce functions" do
    setup do
      @summing = "lambda{|k,vals,r| vals.inject(0){|sum,val| sum+=val } }"
    end
    
    test "runs reduce functions" do
      response = CouchDB.run ["reduce", [@summing], (0...10).map{|i|[i,i*2]}]
      assert_equal [true, [90]], response
    end
    
    test "runs re-reduce functions" do
      response = CouchDB.run ["rereduce", [@summing], (0...10).map{|i|i}]
      assert_equal [true, [45]], response
    end
  end
  
end