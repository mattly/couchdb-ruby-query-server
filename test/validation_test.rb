require File.dirname(__FILE__) + '/test_helper'

context "document update functions" do
  setup do
    @forbidden = <<-RUBY
      lambda{|new_doc, old_doc, user_ctx|
        if new_doc['bad']
          throw :forbidden, "can't be bad"
        end
      }
    RUBY
    set_validation(@forbidden)
  end
  
  def set_validation(func)
    CouchDB.run(["ddoc", "new", "foo", {"validate_doc_update" => func}])
  end
  
  def run_validation(opts={})
    opts[:new] ||= {'good' => true}
    opts[:old] ||= {'bad'  => true}
    opts[:ctx] ||= {}
    CouchDB.run(["ddoc", "foo", ["validate_doc_update"], [opts[:new], opts[:old], opts[:ctx]]])
  end
  
  test "it passes validation" do
    assert_equal 1, run_validation
  end
  
  test "it handles errors correctly" do
    expected = {"forbidden" => "can't be bad"}
    assert_equal expected, run_validation(:new => {"bad" => true})
  end
  
end
