# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_radiobot.ru_session',
  :secret      => 'f949698bd3d3a38874b554760557cda4b7b96ce6d50f78d6e831c4709b47a121ca451e994999c5883cca236efb6390e0b9103459a0292dc45a079de8c50b4868'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
