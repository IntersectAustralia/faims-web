# Your HTTP server, Apache/etc
role :web, 'temp'
# This may be the same as your Web server
role :app, 'temp'
# This is where Rails migrations will run
role :db,  'temp', :primary => true

