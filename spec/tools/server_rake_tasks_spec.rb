require 'spec_helper'
require Rails.root.join('lib/tasks/server')

describe 'Server setup' do

  before :each do
    load File.expand_path('../../../lib/tasks/server.rake', __FILE__)
    ProjectModule.destroy_all
  end

  it 'checks for server updates returns server update to date' do
    Net::HTTP.stub(:get) { File.read('.deployment_version') }
    output = capture(:stdout) do
      check_for_server_updates
    end
    expect(output).to include 'Everything is update to date'
  end

  it 'checks for server updates returns server has updates' do
    Net::HTTP.stub(:get) { '{"version":"1000","tag":"blah"}' }
    output = capture(:stdout) do
      check_for_server_updates
    end
    expect(output).to include 'Found new updates'
  end

  it 'update server does nothing' do
    ServerUpdater.stub(:get_deployment_version) { {'version' => '2.0', 'tag' => 'blah'} }
    ServerUpdater.stub(:get_local_version) { {'version' => '2.0', 'tag' => 'blah'} }
    ServerUpdater.stub(:run_update_script) { 0 }
    output = capture(:stdout) do
      update_server.should == nil
    end
    expect(output).to include "Everything is update to date"
  end

  it 'update server upgrades server' do
    ServerUpdater.stub(:get_deployment_version) { {'version' => '2.1', 'tag' => 'blah'} }
    ServerUpdater.stub(:get_local_version) { {'version' => '2.0', 'tag' => 'blah'} }
    ServerUpdater.stub(:run_update_script) { 2 }
    output = capture(:stdout) do
      update_server.should == 2
    end
    expect(output).to include "Found new updates\nUpdating server... Please wait this could take a while\nFinished updating server"
  end

  it 'update server causes error' do
    ServerUpdater.stub(:get_deployment_version) { {'version' => '2.1', 'tag' => 'blah'} }
    ServerUpdater.stub(:get_local_version) { {'version' => '2.0', 'tag' => 'blah'} }
    ServerUpdater.stub(:run_update_script) { 4 }
    output = capture(:stdout) do
      update_server.should == 4
    end
    expect(output).to include "Found new updates\nUpdating server... Please wait this could take a while\nEncountered an error trying to update server"
  end

  it 'generates properties file with uuid' do
    file = Tempfile.new('server.properties')
    create_server_properties(file.path)
    result = file.read =~ /^server_key=\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
    file.unlink
    result.should be_true
  end
end
