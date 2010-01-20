module Cms::Routes
  def routes_for_bcms_xml_data_feed
    namespace(:cms) do |cms|
      cms.content_blocks :xml_data_feeds
    end  
  end
end