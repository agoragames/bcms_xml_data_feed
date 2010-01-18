require File.join(File.dirname(__FILE__), '/../../test_helper')

class XmlDataFeedTest < ActiveSupport::TestCase

  test "should be able to create new block" do
    assert XmlDataFeed.create!
  end
  
end