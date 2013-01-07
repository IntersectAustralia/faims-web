require File.dirname(__FILE__) + '/../database_generator.rb'
include DatabaseGenerator

def create_projects(size)
  count = 0
  while (count < size) do
    count = count + 1
    p = Project.create(:name => "Project #{count}")
    p.create_project_from(Rails.root.join('features', 'assets').to_s)
    p.archive # create archive file
    puts "Created project #{p.name}"
  end
end

