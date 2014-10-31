#gcal.rb
#
puts	"google calendar cleaner - delete orphaned events in calendars you have access to"
#	accesses google calendar, searches for specific event and deletes it

require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'logger'
require 'json'

API_VERSION = 'v3'
CREDENTIAL_STORE_FILE = "#{$0}-oauth2.json"
DISCOVERY_CACHE = 'discovery.cache'

# oauth2 authentication, gets token and saves it in gcal.rb-oauth2.json
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
  cal = client.discovered_api('calendar', 'v3')
  return cal, client
end

#initiate
cal, client = setup()

#check first for the orphaned event in a known calendar
#ask for calendar ID and event
print "calendar ID, with the orphaned event (name@soundcloud.com): "
STDOUT.flush
calendarId = gets.chomp
#calendarId = 'martin.eisentraut@soundcloud.com'


print "name of event: "
STDOUT.flush
eventname = gets.chomp
#eventname = 'test2'  

#get all events from calendar of interest who match the eventname of interest
calendar = client.execute(
  :api_method => cal.events.list,
  :parameters => {'calendarId' => calendarId,
                  'maxResults' => 250,
                  'q' => eventname})

#output all resulting events with their ID
count = 0
evID = ''
calendar.data.items.each do |item|
  if item["summary"] == eventname
    count = count + 1
    print "   name: " + item.summary + "  start: "
    print item.start.dateTime
    print "  end: "
    print item.end.dateTime
    puts "  id: " + item.id
    evID = item.id
  end
end

#check if there are any events at all
if count < 1
  puts "no such event - script terminated"
else
      
  #ask for event ID
  print "is that the event? [y/n] "
  confirm = gets.chomp!
  if confirm == 'y'
    eventOfInterest = evID
  end
  #STDOUT.flush
  #eventOfInterest = gets.chomp


  #fetch list of all calendars
  listofcalendars = client.execute(:api_method => cal.calendar_list.list)


  #go through all calendars and check if event of interest is present
  listofcalendars.data.items.each do |e|
    #include only user calendars, no resources or groups
    if e.id.include? "@soundcloud.com"  
      puts e.id

      #get the events of the calendar
      calendar = client.execute(
       :api_method => cal.events.list,
       :parameters => {'calendarId' => e.id,
                       'maxResults' => 250,
                       'q' => eventname})
      #go through all events and print/delete them
      calendar.data.items.each do |item|
        if item["id"] == eventOfInterest

          #check if event is a private copy, as indicator that owner does not exist anymore or is suspended
          if (item.private_copy == false)
            puts '   event exists, but is not orphaned'
          else

            #output string
            print "   " + item.summary + " "
            print item.start.dateTime
            print "  "
            print item.end.dateTime
            print " " + item.id + "     "

            #ask for deletion
            print 'delete event [y/n] '
            deleteflag = gets.chomp!
            if deleteflag == 'y'
              result = client.execute(:api_method => cal.events.delete,
                                      :parameters => {'calendarId' => e.id,
                                                      'eventId' => eventOfInterest})
              puts "   done"
            end
          end
        end
      end
    end
  end
end
puts "script completed"

##show all methods
#puts calendar.data.items[236].methods

