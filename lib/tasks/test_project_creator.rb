require File.dirname(__FILE__) + '/../database_generator.rb'
require File.dirname(__FILE__) + '/../../features/support/projects.rb'
include DatabaseGenerator

def create_projects(size)
  (1..size).each do |count|
    p = make_project "Project #{count}"
    puts "Created project #{p.name}"
  end
end

