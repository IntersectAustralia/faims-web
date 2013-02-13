require 'spec_helper'
load "#{Rails.root}/lib/tasks/setup_server.rb"

describe "Server setup" do

  it "generates properties file with uuid" do
    file = Tempfile.new('server.properties')
    create_server_properties(file.path)
    result = file.read =~ /^server_key=\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
    file.unlink
    result.should be_true
  end
end
