class XmlDataFeedPortlet < Portlet
    
  def render
    raise ArgumentError, "No feed URL specified" if self.url.blank?
    @xml_data_feed = XmlDataFeed.find_or_create_by_url(self.url).contents
  end
    
end