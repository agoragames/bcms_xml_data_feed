class CreateXmlDataFeeds < ActiveRecord::Migration
  def self.up
    create_content_table :xml_data_feeds do |t|
      t.string :url 
      t.text :cached_contents 
    end
    
    
    ContentType.create!(:name => "XmlDataFeed", :group_name => "XmlDataFeed")
  end

  def self.down
    ContentType.delete_all(['name = ?', 'XmlDataFeed'])
    CategoryType.all(:conditions => ['name = ?', 'Xml Data Feed']).each(&:destroy)
    #If you aren't creating a versioned table, be sure to comment this out.
    drop_table :xml_data_feed_versions
    drop_table :xml_data_feeds
  end
end
