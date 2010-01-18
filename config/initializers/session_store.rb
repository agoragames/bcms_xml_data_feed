# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bcms_xml_data_feed_session',
  :secret      => '8d36e98ab54f7376af8dabfbffe343bc67710c3f063dd32d7faa82ce0735a2ae4984fb84e6664999d987b3e1d70f02a48fad6f269d0c95f614caffd38467165c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
