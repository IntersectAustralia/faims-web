web_server: bundle exec unicorn -p 3000 -c config/unicorn.rb
discovery_server: bundle exec rake discovery:start
merge_daemon: bundle exec rake merge_daemon:start
worker: bundle exec rake jobs:work
