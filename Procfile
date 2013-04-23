web_server: unicorn -p 3000 -c config/unicorn.rb
discovery_server: rake discovery:start
merge_daemon: rake merge_daemon:start
worker:  bundle exec rake jobs:work
