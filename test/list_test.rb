require File.dirname(__FILE__) + '/test_helper'

module ListTest
  def self.reads; @reads ||= []; end
  def self.writes; @writes ||= []; end
  def self.clear; @reads=[]; @writes=[]; end
end
CouchDB.send :define_method, :read do
  ListTest.reads.shift
end
CouchDB.send :define_method, :write do |arg|
  ListTest.writes.push arg
end

context "basic list functions" do
  setup do
    ListTest.clear
    @entire_list = <<-RUBY
      lambda{|head,req|
        send "<ul>"
        while row = get_row do
          send "<li>"
          send row['count']
          send "</li>"
        end
        "</ul>"
      }
    RUBY
    @two_items = <<-RUBY
      lambda{|head, req|
        send "<ul>"
        2.times { send "<li>"+get_row['count']+"</li>" }
        "</ul>"
      }
    RUBY
    @header_sender = <<-RUBY
      lambda{|head, req|
        start "headers" => {"Content-Type" => "text/plain"}
        "bam"
      }
    RUBY
    create_ddoc "test", {"lists" => {
      "entire" => @entire_list, 
      "two" => @two_items, 
      "headers" => @header_sender
    }}
    ListTest.reads.push ["list_row", {"count"=>"one"}]
    ListTest.reads.push ["list_row", {"count"=>"two"}]
    ListTest.reads.push ["list_row", {"count"=>"three"}]
    ListTest.reads.push ["list_end"]
  end
  
  test "it will read all rows, and buffer chunks" do
    tail = CouchDB.run(['ddoc', 'test', ['lists', 'entire'], [{}, {}]])
    assert_equal ["start", ["<ul>"], {"headers"=>{}}], ListTest.writes.shift
    assert_equal ["chunks", ["<li>", "one", "</li>"]], ListTest.writes.shift
    assert_equal ["chunks", ["<li>", "two", "</li>"]], ListTest.writes.shift
    assert_equal ["chunks", ["<li>", "three", "</li>"]], ListTest.writes.shift
    assert_equal ["end", ["</ul>"]], tail
  end
  
  test "it will read limited rows" do
    tail = CouchDB.run(['ddoc', 'test', ['lists', 'two'], [{}, {}]])
    assert_equal ["start", ["<ul>"], {"headers"=>{}}], ListTest.writes.shift
    assert_equal ["chunks", ["<li>one</li>"]], ListTest.writes.shift
    assert_equal ["end", ["<li>two</li>", "</ul>"]], tail
  end
  
  test "it will send headers" do
    tail = CouchDB.run(['ddoc', 'test', ['lists', 'headers'], [{}, {}]])
    assert_equal ["start", [], {"headers"=>{"Content-Type"=>"text/plain"}}], ListTest.writes.shift
    assert_equal ["end", ["bam"]], tail
  end
end
