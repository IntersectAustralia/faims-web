# Your HTTP server, Apache/etc
role :web, 'temp-staging'
# This may be the same as your Web server
role :app, 'temp-staging'
# This is where Rails migrations will run
role :db,  'temp-staging', :primary => true

