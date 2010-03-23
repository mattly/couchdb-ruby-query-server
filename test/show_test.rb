require File.dirname(__FILE__) + '/test_helper'

context "simple show functions" do
  
  setup do
    @string = "lambda{|doc, req| [doc['title'], doc['body']].join(' - ') }"
    @hash   = <<-RUBY
      lambda{|doc, req|
        resp = {"code" => 200, "headers" => {"X-Foo" => "Bar"}}
        resp["body"] = [doc['title'], doc['body']].join(' - ')
        resp
      }
    RUBY
    @error = "lambda{|doc,req| throw :error, 'error_key', 'error message' }"
    CouchDB.run(["ddoc", "new", "foo", {"shows" => {
      "string" => @string, "hash" => @hash, "error" => @error
    }}])
    @doc = {"title" => "foo", "body" => "bar"}
  end
  
  def run_show(opts={})
    opts[:doc] ||= @doc
    opts[:req] ||= {}
    opts[:design] ||= "string"
    CouchDB.run(["ddoc", "foo", ["shows", opts[:design]], [opts[:doc], opts[:req]]])
  end

  test "handles a returned string" do
    result = run_show
    expected = ["resp", {"body" => "foo - bar"}]
    assert_equal expected, result
  end
  
  test "handles a returned hash" do
    result = run_show({:design => "hash"})
    expected = ["resp", {"body" => "foo - bar", "headers" => {"X-Foo" => "Bar"}, "code" => 200}]
    assert_equal expected, result
  end
  
  test "handles thrown errors" do
    result = run_show({:design => "error"})
    expected = ["error", "error_key", "error message"]
    assert_equal expected, result
  end
  
end