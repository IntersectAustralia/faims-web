require 'spec_helper'
require 'rake'
require 'active_support/core_ext/kernel/reporting'
require File.expand_path('../../../features/support/project_modules', __FILE__)
require File.expand_path('../../../features/support/project_exporters', __FILE__)
require Rails.root.join('spec/tools/helpers/user_spec_helper')

describe ProjectModule do

  before :each do
    load File.expand_path("../../../lib/tasks/modules.rake", __FILE__)
    ProjectModule.destroy_all
  end

  it 'creates a project module from a tarball' do
    ENV['module'] = File.absolute_path("./features/assets/module.tar.bz2")
    create_module
    ProjectModule.all.count.should == 1
    mod = ProjectModule.first
    mod.name.should == "Simple Project"
  end

  it "doesn't create a module if incorrect argument" do
    output = capture(:stdout) do
      ENV['module'] = "./invalid_path"
      create_module
    end
    expect(output).to include "Usage: rake modules:create module=<module tarball>"
    ProjectModule.all.count.should == 0
  end

  it "archives a project module" do
    begin
      project_module = make_project_module('Module 1')
      FileUtils.remove_entry_secure project_module.get_path(:package_archive)
      ENV['key'] = project_module.key
      archive
      tmp_dir = Dir.mktmpdir
      `tar jxf #{project_module.get_path(:package_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(File.join(tmp_dir, "Module_1"))
      entries.include?(project_module.get_name(:db)).should be_true
      entries.include?(project_module.get_name(:ui_schema)).should be_true
      entries.include?(project_module.get_name(:ui_logic)).should be_true
      entries.include?(project_module.get_name(:settings)).should be_true
      entries.include?(project_module.get_name(:properties)).should be_true
      entries.include?(project_module.get_name(:validation_schema)).should be_true
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it "archives a non-existing project module" do
    ENV['key'] = "fake_key"
    output = capture(:stdout) do
      archive
    end
    expect(output).to include "Module does not exist"
  end

  it "deletes a project module" do
    project_module = make_project_module('Module 1')
    ENV['key'] = project_module.key
    delete_module
    ProjectModule.all.count.should == 0
  end

  it "deletes a non-existing project module" do
    ENV['key'] = "fake_key"
    output = capture(:stdout) do
      delete_module
    end
    expect(output).to include "Module does not exist"
  end

  it "restores a project module" do
    project_module = make_project_module('Module 1')
    ENV['key'] = project_module.key
    ProjectModule.all.count.should == 1
    delete_module
    ProjectModule.all.count.should == 0
    restore_module
    ProjectModule.all.count.should == 1
  end

  it "restores a non-existing project module" do
    ENV['key'] = "fake_key"
    output = capture(:stdout) do
      restore_module
    end
    expect(output).to include "Module does not exist"
  end

  it "clears all project modules" do
    make_project_module('Module 1')
    make_project_module('Module 2')
    make_project_module('Module 3')
    ProjectModule.all.count.should == 3
    clear_project_modules
    ProjectModule.all.count.should == 0
  end

end


describe ProjectExporter do

  before :each do
    load File.expand_path("../../../lib/tasks/exporters.rake", __FILE__)
    FileUtils.remove_entry_secure ProjectExporter.exporters_dir if File.exist? ProjectExporter.exporters_dir
  end

  it 'installs a project exporter from a tarball' do
    ENV['exporter'] = File.absolute_path("./features/assets/exporter.tar.gz")
    install_exporter
    ProjectExporter.all.count.should == 1
    exporter = ProjectExporter.all.first
    exporter.name.should == "Exporter 1"
  end

  it 'installs a project exporter with invalid install script' do
    ENV['exporter'] = File.absolute_path("./features/assets/exporter_fail.tar.gz")
    output = capture(:stdout) do
      install_exporter
    end
    ProjectExporter.all.count.should == 0
    expect(output).to include "Exporter failed to install. Please correct the errors in the install script."
  end

  it 'uninstalls a project exporter' do
    exporter = make_project_exporter "Exporter 1"
    ProjectExporter.all.count.should == 1
    ENV['key'] = exporter.key
    uninstall_exporter
    ProjectExporter.all.count.should == 0
  end

  it 'uninstalls a non-existing project exporter' do
    ENV['key'] = "fake_key"
    output = capture(:stdout) do
      uninstall_exporter
    end
    expect(output).to include "Exporter does not exist"
  end

  it 'clears all project exporters' do
    make_project_exporter "Exporter 1"
    make_project_exporter "Exporter 2"
    make_project_exporter "Exporter 3"
    ProjectExporter.all.count.should == 3
    clear_exporters
    ProjectExporter.all.count.should == 0
  end

end

describe User do

  before :each do
    load File.expand_path("../../../lib/tasks/users.rake", __FILE__)
  end

  it 'creates a user' do
    should_receive(:ask).and_return("Joe", "Bloggs", "test@intersect.org.au", "Pass.123", "Pass.123")
    create_user
    new_user = User.last
    new_user.first_name.should == "Joe"
    new_user.last_name.should == "Bloggs"
    new_user.email.should == "test@intersect.org.au"
  end

  it 'creates a user with non-matching passwords' do
    should_receive(:ask).and_return("Joe", "Bloggs", "test@intersect.org.au", "Pass.123", "Pass.234")
    lambda do
      create_user
    end.should raise_error("Passwords don't match")
  end

  it 'creates a user with invalid arguments' do
    should_receive(:ask).and_return("Joe", "Bloggs", "test", "Pass.123", "Pass.123")
    lambda do
      create_user
    end.should raise_error("Error creating user. Check the entered email is valid and that the password is between 6-20 characters " +
                                   "and contains at least one uppercase letter, one lowercase letter, one digit and one symbol")
  end

  it 'deletes a user' do
    user = make_user "Joe", "Bloggs", "test@intersect.org.au", "Pass.123"
    ENV['email'] = user.email
    delete_user
    User.find_by_email("test@intersect.org.au").should == nil
  end

  it 'deletes a non-existing user' do
    ENV['email'] = "invalid_email"
    lambda do
      delete_user
    end.should raise_error("User does not exist")
  end
end