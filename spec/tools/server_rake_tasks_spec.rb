require 'spec_helper'
require Rails.root.join('lib/tasks/setup_server')

describe 'Server setup' do

  before :each do
    load File.expand_path("../../../lib/tasks/server.rake", __FILE__)
    ProjectModule.destroy_all
  end

  it 'checks for server updates returns server update to date' do
  end

  it 'checks for server updates returns server has updates' do
  end

  it 'update server does nothing' do
  end

  it 'update server upgrades server' do
  end

  it 'generates properties file with uuid' do
    file = Tempfile.new('server.properties')
    create_server_properties(file.path)
    result = file.read =~ /^server_key=\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
    file.unlink
    result.should be_true
  end
end
