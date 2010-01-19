require "open-uri"
require "timeout"
require "xmlsimple"

class XmlDataFeed < ActiveRecord::Base
  acts_as_content_block

  TTL = 30.minutes
  TTL_ON_ERROR = 10.minutes
  TIMEOUT = 10 # In seconds
  
  def contents
    if expired?
      load_remote_feed
    else
      load_cached_feed
    end
    @contents
  end

  private

  def load_remote_feed
    begin
      xml_feed_data = remote_feed_contents
      @contents = parse_xml_to_hash(xml_feed_data)
      logger.info("Loaded feed: #{url}")
      self.cached_contents = xml_feed_data
      self.expires_at = Time.now.utc + TTL
      save
      
      logger.error("Feed headers: #{xml_feed_data.meta.inspect}") if xml_feed_data.respond_to?(:meta)

      # set returned cache-control headers
      # remote_contents.meta
      # expires header?
      # max age?
      # date?
      # etag?
    rescue Exception => e
      logger.error("Loading feed '#{url}' failed with  #{e.message}")
      if self.cached_contents
        load_cached_feed
        update_attribute(:expires_at, Time.now.utc + TTL_ON_ERROR)
      end
    end
  end
  
  def load_cached_feed
    @contents ||= parse_xml_to_hash(self.cached_contents)
    logger.info("Loaded feed '#{url}' from cache")
  end
  
  def remote_feed_contents
    Timeout.timeout(TIMEOUT) { open(url).read }
  end
  
  def expired?
    self.cached_contents.nil? || (self.expires_at.nil? || self.expires_at < Time.now.utc)
  end

  def parse_xml_to_hash(xml_feed_data = '')
    XmlSimple.xml_in(xml_feed_data, { 'KeyAttr' => 'name' })
  end

  
#  Combine Expiration & Validation
#  Back-end sets Cache-control: public, max=age=60 and ETag: abcdef012345
#  In < 60 seconds, cache-control takes precedence
#  After 60 seconds, it queries back-end using ETag
#  Back end can then send back a 304 not modified with a new Cache-control: public, max-age: 60
#
#
#  Read more: http://pivotallabs.com/users/spierson/blog/articles/842-railsconf-http-s-best-kept-secret-caching-ryan-tomayko-heroku-#ixzz0czyFcaPT
end
