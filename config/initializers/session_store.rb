# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ukcompanies_session',
  :secret      => '9f50b00741af2125afc915a8697b9bf6d51f293566e0a7c8e83f7555ba0cbe7ef65fc399eb421f7d61f893a3868816bf4085a81ff0fe1ddd3f53fdc540aac7d2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
