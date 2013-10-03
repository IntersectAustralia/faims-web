require File.dirname(__FILE__) + '/../../features/support/project_modules.rb'

def create_project_modules(size)
  (1..size).each do |count|
    p = make_project_module "Module #{count}"
    puts "Created module #{p.name}"
  end
end

