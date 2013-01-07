# Your HTTP server, Apache/etc
role :web, 'faims-qa.intersect.org.au'
# This may be the same as your Web server
role :app, 'faims-qa.intersect.org.au'
# This is where Rails migrations will run
role :db, 'faims-qa.intersect.org.au', :primary => true

