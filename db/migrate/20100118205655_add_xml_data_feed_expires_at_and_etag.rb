class AddXmlDataFeedExpiresAtAndEtag < ActiveRecord::Migration
  def self.up
    add_column :xml_data_feeds, :expires_at, :datetime
    add_column :xml_data_feeds, :etag, :string
  end

  def self.down
    remove_column :xml_data_feeds, :expires_at
    remove_column :xml_data_feeds, :etag
  end
end
