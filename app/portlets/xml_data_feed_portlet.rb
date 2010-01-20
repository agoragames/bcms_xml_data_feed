class XmlDataFeedPortlet < Portlet

  def render
    @xml_data_feed = XmlDataFeed.find(self.xml_data_feed_id).contents
  end
    
end