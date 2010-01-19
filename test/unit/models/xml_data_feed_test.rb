require File.join(File.dirname(__FILE__), '/../../test_helper')

class XmlDataXmlDataFeedTest < ActiveSupport::TestCase
  def setup
    @xml_data_feed = XmlDataFeed.create!(:url => "http://example.com/blog.xml")
    @contents = "<xml_data_feed>Some xml_data_feed</xml_data_feed>"
    @parsed_contents = XmlSimple.xml_in(@contents, { 'KeyAttr' => 'name' })

    now = Time.now
    Time.stubs(:now).returns(now) # Freeze time
    
    # small timeout for testing purposes
    XmlDataFeed.send(:remove_const, :TIMEOUT)
    XmlDataFeed.const_set(:TIMEOUT, 1)
  end
  
  test "remote_feed_contents should fetch the xml_data_feed" do
    @xml_data_feed.expects(:open).with("http://example.com/blog.xml").returns(stub(:read => @contents))
    assert_equal @contents, @xml_data_feed.send(:remote_feed_contents)
  end
  
  test "remote_feed_contents should raise a Timeout::Error if fetching the xml_data_feed takes longer then XmlDataFeed::TIMEOUT" do
    def @xml_data_feed.open(url)
      sleep(2)
      stubs(:read => "bla")
    end
    
    assert_raise(Timeout::Error) { @xml_data_feed.send(:remote_feed_contents) }
  end
  
  test "contents with no expiry should return the remote contents and save it" do
    @xml_data_feed.expires_at = nil
    should_get_remote_feed_contents_and_parse
  end
  
  test "contents with an expiry in the past return the remote contents and save it" do
    @xml_data_feed.expires_at = Time.now - 1.hour
    should_get_remote_feed_contents_and_parse
  end
  
  def should_get_remote_feed_contents_and_parse
    @xml_data_feed.stubs(:remote_feed_contents).returns(@contents)
    #XmlSimple.expects(:xml_in).with(@contents)
    
    assert_equal @parsed_contents, @xml_data_feed.contents
    @xml_data_feed.reload
    assert_equal @contents, @xml_data_feed.read_attribute(:cached_contents)
    
    # I think the to_i is necessary because of a lack of precision provided by sqlite3. I think.
    # Anyway, without it the comparison fails.
    assert_equal (Time.now.utc + XmlDataFeed::TTL).to_i, @xml_data_feed.expires_at.to_i
  end
  
  test "contents with the expiry in the future should return the cached contents" do
    @xml_data_feed.expires_at = Time.now + 1.hour
    @xml_data_feed.write_attribute(:cached_contents, @contents)
    
    assert_equal @parsed_contents, @xml_data_feed.contents
  end
  
  test "TTL of cached contents should be extended if there is an error fetching the remote contents, or parsing the xml_data_feed" do
    [StandardError, Timeout::Error, Exception].each do |exception|
      @xml_data_feed.expires_at = Time.now - 1.hour
      @xml_data_feed.stubs(:remote_feed_contents).raises(exception)
      @xml_data_feed.write_attribute(:cached_contents, @contents)
      
      assert_equal @parsed_contents, @xml_data_feed.contents
      assert_equal Time.now.utc + XmlDataFeed::TTL_ON_ERROR, @xml_data_feed.expires_at
    end
  end
  
  test "Cached contents can be larger than 64Kb of text in a xml_data_feed" do
    xml_data_feed = XmlDataFeed.new(:url => 'http://www.foo.com', :cached_contents => '<xml_data_feed>' + 'w' * 300000 + '</xml_data_feed>', :expires_at => Time.now + 15.minutes)
    xml_data_feed.save
    
    assert_equal 'http://www.foo.com', xml_data_feed.url
    assert_equal '<xml_data_feed>' + 'w' * 300000 + '</xml_data_feed>', xml_data_feed.cached_contents
  end
end