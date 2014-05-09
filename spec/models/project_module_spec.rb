require 'spec_helper'
require File.expand_path('../../../features/support/project_modules', __FILE__)

describe ProjectModule do

  describe 'Validations' do
    it { should_not allow_value('').for(:name) }

    it { should_not allow_value('Module \\').for(:name) }
    it { should_not allow_value('Module /').for(:name) }
    it { should_not allow_value('Module ?').for(:name) }
    it { should_not allow_value('Module %').for(:name) }
    it { should_not allow_value('Module *').for(:name) }
    it { should_not allow_value('Module :').for(:name) }
    it { should_not allow_value('Module |').for(:name) }
    it { should_not allow_value('Module "').for(:name) }
    it { should_not allow_value('Module \'').for(:name) }
    it { should_not allow_value('Module <').for(:name) }
    it { should_not allow_value('Module >').for(:name) }
    it { should_not allow_value('Module .').for(:name) }

    it { should allow_value('Module 1').for(:name) }
    it { should allow_value('Module Test 1').for(:name) }
    it { should allow_value('Module Test #1').for(:name) }
    it { should allow_value('Module Test @Something').for(:name) }

    it 'project_module names should be unique' do
      p1 = FactoryGirl.build(:project_module, :name => 'Module 1')
      p2 = FactoryGirl.build(:project_module, :name => 'Module 2')
      p3 = FactoryGirl.build(:project_module, :name => 'Module 1')
      p4 = FactoryGirl.build(:project_module, :name => 'Module    1')
      p5 = FactoryGirl.build(:project_module, :name => '    Module 1    ')
      p1.save.should == true
      p2.save.should == true
      p3.save.should == true
      p4.save.should == true
      p5.save.should == true
    end

    it { should_not allow_value('').for(:key) }

    it 'project_module keys should be unique' do
      uuid = SecureRandom.uuid
      p1 = FactoryGirl.build(:project_module, :key => uuid)
      p2 = FactoryGirl.build(:project_module, :key => uuid)
      p1.save.should == true
      p2.save.should == false
    end
  end

  describe 'Should order by name' do
    it do
      p1 = FactoryGirl.create(:project_module, :name => 'b Module')
      p2 = FactoryGirl.create(:project_module, :name => 'a Module')
      p3 = FactoryGirl.create(:project_module, :name => 'c Module')
      p4 = FactoryGirl.create(:project_module, :name => 'B Module')
      p5 = FactoryGirl.create(:project_module, :name => 'A Module')
      p6 = FactoryGirl.create(:project_module, :name => 'C Module')
      project_modules = ProjectModule.all
      project_modules.should == [p2, p5, p1, p4, p3, p6]
    end
  end

  it 'Archiving settings' do
    begin
      project_module = make_project_module('Module 1')
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project_module.get_path(:settings_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?(project_module.get_name(:ui_schema)).should be_true
      entries.include?(project_module.get_name(:ui_logic)).should be_true
      entries.include?(project_module.get_name(:settings)).should be_true
      entries.include?(project_module.get_name(:properties)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it 'Archiving settings with project_module properties' do
    begin
      project_module = make_project_module('Module 1')
      project_module.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project_module.get_path(:settings_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?(project_module.get_name(:ui_schema)).should be_true
      entries.include?(project_module.get_name(:ui_logic)).should be_true
      entries.include?(project_module.get_name(:settings)).should be_true
      entries.include?(project_module.get_name(:properties)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it 'Archiving data directory' do
    begin
      project_module = make_project_module('Module 1')
      FileHelper.touch_file(project_module.get_path(:data_files_dir) + 'test1')
      FileHelper.touch_file(project_module.get_path(:data_files_dir) + 'test2')
      FileUtils.mkdir_p project_module.get_path(:data_files_dir) + 'dir1/dir2'
      FileHelper.touch_file(project_module.get_path(:data_files_dir) + 'dir1/dir2/test3')
      project_module.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project_module.get_path(:data_files_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Archiving data directory' do
    begin
      project_module = make_project_module('Module 1')
      FileHelper.touch_file(project_module.get_path(:app_files_dir) + 'test1')
      FileHelper.touch_file(project_module.get_path(:app_files_dir) + 'test2')
      FileUtils.mkdir_p project_module.get_path(:app_files_dir) + 'dir1/dir2'
      FileHelper.touch_file(project_module.get_path(:app_files_dir) + 'dir1/dir2/test3')
      project_module.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project_module.get_path(:app_files_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Archiving database' do
    begin
      project_module = make_project_module('Module 1')
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project_module.get_path(:db_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?(project_module.get_name(:db)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Create temp data archive for directory' do
    begin
      project_module = make_project_module('Module 1')
      FileHelper.touch_file(project_module.get_path(:data_files_dir) + 'test1')
      FileHelper.touch_file(project_module.get_path(:data_files_dir) + 'test2')
      FileUtils.mkdir_p project_module.get_path(:data_files_dir) + 'dir1/dir2'
      FileHelper.touch_file(project_module.get_path(:data_files_dir) + 'dir1/dir2/test3')
      archive = project_module.create_temp_dir_archive(project_module.get_path(:data_files_dir))
      tmp_dir = Dir.mktmpdir
      `tar zxf #{archive} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Packaging project module' do
    begin
      project_module = make_project_module('Module 1')
      FileHelper.touch_file(project_module.get_path(:project_module_dir) + 'test1')
      FileHelper.touch_file(project_module.get_path(:project_module_dir) + 'test2')
      FileUtils.mkdir_p project_module.get_path(:project_module_dir) + 'dir1/dir2'
      FileHelper.touch_file(project_module.get_path(:project_module_dir) + 'dir1/dir2/test3')
      FileHelper.touch_file(project_module.get_path(:project_module_dir) + '.lock')
      FileHelper.touch_file(project_module.get_path(:project_module_dir) + '.dirt')
      FileHelper.touch_file(project_module.get_path(:project_module_dir) + 'tmp')
      project_module.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar jxf #{project_module.get_path(:package_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir + '/module')
      entries.include?(project_module.get_name(:db)).should be_true
      entries.include?(project_module.get_name(:ui_schema)).should be_true
      entries.include?(project_module.get_name(:ui_logic)).should be_true
      entries.include?(project_module.get_name(:settings)).should be_true
      entries.include?(project_module.get_name(:properties)).should be_true
      entries.include?(project_module.get_name(:validation_schema)).should be_true
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
      entries.include?('.lock').should be_false # ignore dot files
      entries.include?('.dirt').should be_false # ignore dot files
      entries.include?('tmp').should be_false # ignore tmp dir
      entries.include?('hash_sum').should be_true # hash file
    rescue Exception => e
      raise e
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it 'Creating project_module initialise directory' do
    project_module = make_project_module('Module 1')
    File.exists?(project_module.get_path(:project_module_dir)).should be_true
    File.exists?(project_module.get_path(:tmp_dir)).should be_true
    File.exists?(project_module.get_path(:server_files_dir)).should be_true
    File.exists?(project_module.get_path(:app_files_dir)).should be_true
  end

  it 'Updating settings causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    sleep(1)
    project_module.settings_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project_module.package_dirty?.should be_true
  end

  it 'Updating database causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    sleep(1)
    project_module.db_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project_module.package_dirty?.should be_true
  end

  it 'Adding data files causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    sleep(1)
    FileUtils.touch project_module.get_path(:data_files_dir) + '/temp'
    project_module.package_dirty?.should be_true
  end

  it 'Updating data files causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    FileUtils.touch project_module.get_path(:data_files_dir) + '/temp'
    project_module.update_archives
    project_module.package_dirty?.should be_false
    sleep(1)
    project_module.data_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project_module.package_dirty?.should be_true
  end

  it 'Adding app files causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    sleep(1)
    FileUtils.touch project_module.get_path(:app_files_dir) + '/temp'
    project_module.package_dirty?.should be_true
  end

  it 'Updating app files causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    FileUtils.touch project_module.get_path(:app_files_dir) + '/temp'
    project_module.update_archives
    project_module.package_dirty?.should be_false
    sleep(1)
    project_module.app_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project_module.package_dirty?.should be_true
  end

  it 'Adding server files causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    sleep(1)
    FileUtils.touch project_module.get_path(:server_files_dir) + '/temp'
    project_module.package_dirty?.should be_true
  end

  it 'Updating server files causes package to rearchive' do
    project_module = make_project_module('Module 1')
    project_module.package_dirty?.should be_false
    FileUtils.touch project_module.get_path(:server_files_dir) + '/temp'
    project_module.update_archives
    project_module.package_dirty?.should be_false
    sleep(1)
    project_module.server_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project_module.package_dirty?.should be_true
  end

end
