require 'spec_helper'
require 'rake'
require 'active_support/core_ext/kernel/reporting'
require File.expand_path('../../../features/support/project_modules', __FILE__)
require File.expand_path('../../../features/support/project_exporters', __FILE__)
require Rails.root.join('spec/tools/helpers/user_spec_helper')

describe ProjectModule do

  before :each do
    load File.expand_path("../../../lib/tasks/modules.rake", __FILE__)
    Rake::Task.define_task(:environment)
    ProjectModule.destroy_all
  end

  it 'creates a project module from a tarball' do
    ENV['module'] = File.absolute_path("./features/assets/module.tar.bz2")
    Rake::Task["modules:create"].invoke
    ProjectModule.all.count.should == 1
    mod = ProjectModule.first
    mod.name.should == "Simple Project"
  end

  it "doesn't create a module if incorrect argument" do
    output = capture(:stdout) do
      Rake::Task["modules:create"].invoke
      ENV['module'] = "./invalid_path"
      Rake::Task["modules:create"].invoke
    end
    expect(output).to include "Usage: rake modules:create module=<module tarball>"
    ProjectModule.all.count.should == 0
  end

  it "archives a project module" do
    begin
      project_module = make_project_module('Module 1')
      FileUtils.remove_entry_secure project_module.get_path(:package_archive)
      ENV['key'] = project_module.key
      Rake::Task["modules:archive"].invoke
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
      Rake::Task["modules:archive"].invoke
    end
    expect(output).to include "Module does not exist"
  end

  it "deletes a project module" do
    project_module = make_project_module('Module 1')
    ENV['key'] = project_module.key
    Rake::Task["modules:delete"].invoke
    ProjectModule.all.count.should == 0
  end

  it "deletes a non-existing project module" do
    ENV['key'] = "fake_key"
    output = capture(:stdout) do
      Rake::Task["modules:delete"].invoke
    end
    expect(output).to include "Module does not exist"
  end

  it "clears all project modules" do
    make_project_module('Module 1')
    make_project_module('Module 2')
    make_project_module('Module 3')
    ProjectModule.all.count.should == 3
    Rake::Task["modules:clear"].invoke
    ProjectModule.all.count.should == 0
  end

end


describe ProjectExporter do

  before :each do
    load File.expand_path("../../../lib/tasks/exporters.rake", __FILE__)
    Rake::Task.define_task(:environment)
    FileUtils.remove_entry_secure ProjectExporter.exporters_dir if File.exist? ProjectExporter.exporters_dir
  end

  it 'installs a project exporter from a tarball' do
    ENV['exporter'] = File.absolute_path("./features/assets/exporter.tar.gz")
    Rake::Task["exporters:install"].invoke
    ProjectExporter.all.count.should == 1
    exporter = ProjectExporter.all.first
    exporter.name.should == "Exporter 1"
  end

  it 'installs a project exporter with invalid install script' do
    ENV['exporter'] = File.absolute_path("./features/assets/exporter_fail.tar.gz")
    output = capture(:stdout) do
      Rake::Task["exporters:install"].invoke
    end
    ProjectExporter.all.count.should == 0
    expect(output).to include "Exporter failed to install. Please correct the errors in the install script."
  end

  it 'uninstalls a project exporter' do
    exporter = make_project_exporter "Exporter 1"
    ProjectExporter.all.count.should == 1
    ENV['key'] = exporter.key
    Rake::Task["exporters:uninstall"].invoke
    ProjectExporter.all.count.should == 0
  end

  it 'uninstalls a non-existing project exporter' do
    ENV['key'] = "fake_key"
    output = capture(:stdout) do
      Rake::Task["exporters:uninstall"].invoke
    end
    expect(output).to include "Exporter does not exist"
  end

  it 'clears all project exporters' do
    make_project_exporter "Exporter 1"
    make_project_exporter "Exporter 2"
    make_project_exporter "Exporter 3"
    ProjectExporter.all.count.should == 3
    Rake::Task["exporters:clear"].invoke
    ProjectExporter.all.count.should == 0
  end

end

describe User do

  before :each do
    load File.expand_path("../../../lib/tasks/users.rake", __FILE__)
    Rake::Task.define_task(:environment)
    # User.find_by_email("test@intersect.org.au").destroy if User.find_by_email("test@intersect.org.au") != nil
  end

  it 'creates a user' do
    $stdin.should_receive(:gets).and_return("Joe\n", "Bloggs\n", "test@intersect.org.au\n", "Pass.123\n", "Pass.123\n")
    Rake::Task["users:create"].invoke
    new_user = User.last
    new_user.first_name.should == "Joe"
    new_user.last_name.should == "Bloggs"
    new_user.email.should == "test@intersect.org.au"
  end

  it 'creates a user with non-matching passwords' do
    $stdin.should_receive(:gets).and_return("Joe\n", "Bloggs\n", "test@intersect.org.au\n", "Pass.123\n", "Pass.234\n")
    output = capture(:stderr) do
      Rake::Task["users:create"].invoke
    end
    User.all.count.should == 0
    expect(output).to include "Passwords don't match"
  end

  it 'creates a user with invalid arguments' do
    $stdin.should_receive(:gets).and_return("Joe\n", "Bloggs\n", "test\n", "Pass.123\n", "Pass.123\n")
    output = capture(:stdout) do
      Rake::Task["users:create"].invoke
    end
    User.all.count.should == 0
    expect(output).to include "Error creating user."
  end

  it 'deletes a user' do
    user = make_user "Joe", "Bloggs", "test@intersect.org.au", "Pass.123"
    ENV['email'] = user.email
    Rake::Task["users:delete"].invoke
    User.find_by_email("test@intersect.org.au").should == nil
  end
end