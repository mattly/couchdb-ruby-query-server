require File.dirname(__FILE__) + '/test_helper'

context "reading functions" do
  setup do
    CouchDB::Sandbox.safe = false
  end
  
  test "it turns a proc string into a Proc" do
    str = "lambda{|foo| foo * 2 }"
    ret = CouchDB::Sandbox.make_proc(str)
    assert_kind_of Proc, ret
    assert_equal 6, ret.call(3)
  end
  
  test "it evals a proc with context" do
    str = "bar = 2; lambda{|foo| foo * bar}"
    ret = CouchDB::Sandbox.make_proc(str)
    assert_kind_of Proc, ret
    assert_equal 6, ret.call(3)
  end
  
  test "it returns an error if the code does not return a proc" do
    str = "bar = 2"
    response = CouchDB::Sandbox.make_proc(str)
    assert_kind_of response, Array
    assert_equal response.shift, 'error'
    assert_equal response.shift, 'compilation_error'
  end
end

context "with safe mode" do
  setup do
    CouchDB::Sandbox.safe = true
  end
  
  test "it creates tainted/untrusted procs" do
    str = "lambda {|doc| doc['foo']}"
    ret = CouchDB::Sandbox.make_proc(str)
    assert ret.tainted?
    if RUBY_VERSION.to_f > 1.9
      assert ret.untrusted?
    end
  end
  
  test "it can't change the safe level" do
    assert_raises SecurityError do
      CouchDB::Sandbox.run("CouchDB::Sandbox.safe = false")
    end
  end
  
  test "operates in $SAFE level 4" do
    assert_equal 4, CouchDB::Sandbox.run("$SAFE")
  end
  
  test "it prevents system operations" do
    assert_raises SecurityError do
      CouchDB::Sandbox.run("`ls`")
    end
  end
  
  test "it prevents system operations from created procs" do
    func = CouchDB::Sandbox.make_proc("lambda{ `ls` }")
    assert_raises SecurityError do
      func.call
    end
  end
  
  test "it prevents writing to STDIO" do
    ['STDOUT', 'STDERR'].each do |out|
      str = "#{out}.puts 'foo'"
      assert_raises SecurityError do
        CouchDB::Sandbox.run(str)
      end
    end
  end
end

context "without safe mode" do
  setup do
    CouchDB::Sandbox.safe = false
  end
  
  test "does not raise security errors" do
    assert_nothing_raised do
      CouchDB::Sandbox.run("`ls`")
    end
  end
end
