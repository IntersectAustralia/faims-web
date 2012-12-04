require File.dirname(__FILE__) + '/sample_data_populator.rb'
begin
  namespace :db do  
    desc "Populate the database with some sample data for testing"
    task :populate => :environment do  
      populate_data
    end
  end  
rescue LoadError  
  puts "It looks like some Gems are missing: please run bundle install"  
end