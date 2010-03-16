require File.dirname(__FILE__) + '/test_helper'

context "teaching a design document" do
  setup do
    CouchDB::Design.documents.clear
    @ddoc = {"_id" => "foo"}
    CouchDB.run(["ddoc", "new", "foo", @ddoc])
  end
  
  test "stores the document" do
    assert_equal @ddoc, CouchDB::Design.documents["foo"]
  end
  
  test "survives a reset" do
    CouchDB.run(["reset"])
    assert 1, CouchDB::Design.documents.size
  end
  
end