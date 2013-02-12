require 'spec_helper'
load "#{Rails.root}/lib/tasks/setup_server.rb"

describe "Server setup" do

  it "generates properties file with uuid" do
    file = Tempfile.new('server.properties')
    create_server_properties(file.path)
    uuid = file.read.gsub('server_key=', '')
    parts = uuid.split('-')
    [8, 4, 4, 4, 12].each do |length|
      parts.shift.length.should == length
    end
    file.unlink
  end
end
