require File.dirname(__FILE__) + '/test_helper'

context "map functions" do
  setup do
    CouchDB::Sandbox.safe = true
    CouchDB::View.reset
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
  
  test "are cleared on reset" do
    CouchDB.run ["add_fun", "lambda{|doc| emit('foo', 'bar')}"]
    assert_operator 0, :<=, CouchDB.run(['map_doc', {}]).size
    assert CouchDB.run(['reset'])
    assert_equal 0, CouchDB.run(['map_doc', {}]).size
  end
end

context "reduce functions" do
  setup do
    CouchDB::Sandbox.safe = true
    @summing = "lambda{|k,vals,r| vals.inject(0){|sum,val| sum + val } }"
    @concat  = "lambda{|k,vals,rereduce| rereduce ? vals.join('_') : vals.join(':') }"
  end
  
  test "runs reduce functions" do
    response = CouchDB.run ["reduce", [@summing, @concat], (0...10).map{|i|[i,i*2]}]
    assert_equal [true, [90, "0:2:4:6:8:10:12:14:16:18"]], response
  end
  
  test "runs re-reduce functions" do
    response = CouchDB.run ["rereduce", [@summing, @concat], (0...10).map{|i|i}]
    assert_equal [true, [45, "0_1_2_3_4_5_6_7_8_9"]], response
  end
end