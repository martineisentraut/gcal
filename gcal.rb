#gcal.rb

#	google calendar project
#	goal: access my google calendar, search for a specific event and delete it

require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'logger'
require 'json'

=begin
#initialize the client
#client = Google::APIClient.new(
#	:application_name => 'GoogleCalendarCleaner',
#	:application_version => '1.0.0' )

#initialize calendar api
#cal = client.discovered_api('calendar', 'v3')

#load client secret from client_secret.json
#client_secrets = Google::APIClient::ClientSecrets.load('client_secret.json')

#flow = Google::APIClient::InstalledAppFlow.new(
#	:client_id => client_secrets.client_id,
#	:client_secret => client_secrets.client_secret,
#	:scope => ['https://www.googleapis.com/auth/calendar'])

#client.authorization = flow.authorize

##File.open('./.refresh', 'w') { |file| file.write client.authorization.refresh_token}

CREDENTIAL_STORE_FILE = "client_secret.json"
=end


CREDENTIAL_STORE_FILE = ARGV[0]+"-oauth2.json"
API_VERSION = "v3"

def setup()
  log_file = File.open('gcal.log', 'a+')
  log_file.sync = true
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG

  client = Google::APIClient.new(
	:application_name => 'GoogleCalendarCleaner',
	:application_version => '1.0.0' )

  # FileStorage stores auth credentials in a file, so they survive multiple runs
  # of the application. This avoids prompting the user for authorization every
  # time the access token expires, by remembering the refresh token.
  # Note: FileStorage is not suitable for multi-user applications.

file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
=begin
#check if oauth2 token file in json format exists, if yes proceed, if no initialize
if File.exist?(CREDENTIAL_STORE_FILE)
  puts "file exists"
  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
else
  puts "file does not exists"
  (FileStorage) initialize(CREDENTIAL_STORE_FILE)
  #file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
end
=end

  
  if file_storage.authorization.nil?
    client_secrets = Google::APIClient::ClientSecrets.load
    # The InstalledAppFlow is a helper class to handle the OAuth 2.0 installed
    # application flow, which ties in with FileStorage to store credentials
    # between runs.
    flow = Google::APIClient::InstalledAppFlow.new(
      :client_id => client_secrets.client_id,
      :client_secret => client_secrets.client_secret,
      :scope => ['https://www.googleapis.com/auth/calendar']
    )
    client.authorization = flow.authorize(file_storage)
  else
    client.authorization = file_storage.authorization
  end



  cal = client.discovered_api('calendar', API_VERSION)
puts "yepp"
  return client, cal

  
end

client, cal = setup()


=begin
rescue Exception => e
	
end
result = client.execute(
	:api_method => cal.events.list,
	#:parameters => {'calendarId' => 'primary'})
	#:parameters => {'calendarId' => 'martin.eisentraut@soundcloud.com'})
	:parameters => {'calendarId' => 'dominik@soundcloud.com'})

=end

#y result

#result.data.items[236]["summary"]

#map 
#select
#each
#summary

#objects
#moduls
