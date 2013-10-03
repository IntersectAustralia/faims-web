require 'spec_helper'
require File.expand_path('../../../features/support/projects', __FILE__)

describe Project do

  describe 'Validations' do
    it { should_not allow_value('').for(:name) }

    it { should_not allow_value('Project \\').for(:name) }
    it { should_not allow_value('Project /').for(:name) }
    it { should_not allow_value('Project ?').for(:name) }
    it { should_not allow_value('Project %').for(:name) }
    it { should_not allow_value('Project *').for(:name) }
    it { should_not allow_value('Project :').for(:name) }
    it { should_not allow_value('Project |').for(:name) }
    it { should_not allow_value('Project "').for(:name) }
    it { should_not allow_value('Project \'').for(:name) }
    it { should_not allow_value('Project <').for(:name) }
    it { should_not allow_value('Project >').for(:name) }
    it { should_not allow_value('Project .').for(:name) }

    it { should allow_value('Project 1').for(:name) }
    it { should allow_value('Project Test 1').for(:name) }
    it { should allow_value('Project Test #1').for(:name) }
    it { should allow_value('Project Test @Something').for(:name) }

    it 'project names should be unique' do
      p1 = FactoryGirl.build(:project, :name => 'Project 1')
      p2 = FactoryGirl.build(:project, :name => 'Project 2')
      p3 = FactoryGirl.build(:project, :name => 'Project 1')
      p4 = FactoryGirl.build(:project, :name => 'Project    1')
      p5 = FactoryGirl.build(:project, :name => '    Project 1    ')
      p1.save.should == true
      p2.save.should == true
      p3.save.should == true
      p4.save.should == true
      p5.save.should == true
    end

    it { should_not allow_value('').for(:key) }

    it 'project keys should be unique' do
      uuid = SecureRandom.uuid
      p1 = FactoryGirl.build(:project, :key => uuid)
      p2 = FactoryGirl.build(:project, :key => uuid)
      p1.save.should == true
      p2.save.should == false
    end
  end

  describe 'Should order by name' do
    it do
      p1 = FactoryGirl.create(:project, :name => 'b Project')
      p2 = FactoryGirl.create(:project, :name => 'a Project')
      p3 = FactoryGirl.create(:project, :name => 'c Project')
      p4 = FactoryGirl.create(:project, :name => 'B Project')
      p5 = FactoryGirl.create(:project, :name => 'A Project')
      p6 = FactoryGirl.create(:project, :name => 'C Project')
      projects = Project.all
      projects.should == [p2, p5, p1, p4, p3, p6]
    end
  end

  it 'Archiving settings' do
    begin
      project = make_project('Project 1')
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project.get_path(:settings_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?(project.get_name(:ui_schema)).should be_true
      entries.include?(project.get_name(:ui_logic)).should be_true
      entries.include?(project.get_name(:settings)).should be_true
      entries.include?(project.get_name(:properties)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it 'Archiving settings with project properties' do
    begin
      project = make_project('Project 1')
      project.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project.get_path(:settings_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?(project.get_name(:ui_schema)).should be_true
      entries.include?(project.get_name(:ui_logic)).should be_true
      entries.include?(project.get_name(:settings)).should be_true
      entries.include?(project.get_name(:properties)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it 'Archiving data directory' do
    begin
      project = make_project('Project 1')
      FileHelper.touch_file(project.get_path(:data_files_dir) + 'test1')
      FileHelper.touch_file(project.get_path(:data_files_dir) + 'test2')
      FileUtils.mkdir_p project.get_path(:data_files_dir) + 'dir1/dir2'
      FileHelper.touch_file(project.get_path(:data_files_dir) + 'dir1/dir2/test3')
      project.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project.get_path(:data_files_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Archiving data directory' do
    begin
      project = make_project('Project 1')
      FileHelper.touch_file(project.get_path(:app_files_dir) + 'test1')
      FileHelper.touch_file(project.get_path(:app_files_dir) + 'test2')
      FileUtils.mkdir_p project.get_path(:app_files_dir) + 'dir1/dir2'
      FileHelper.touch_file(project.get_path(:app_files_dir) + 'dir1/dir2/test3')
      project.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project.get_path(:app_files_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Archiving database' do
    begin
      project = make_project('Project 1')
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project.get_path(:db_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?(project.get_name(:db)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Create temp data archive for directory' do
    begin
      project = make_project('Project 1')
      FileHelper.touch_file(project.get_path(:data_files_dir) + 'test1')
      FileHelper.touch_file(project.get_path(:data_files_dir) + 'test2')
      FileUtils.mkdir_p project.get_path(:data_files_dir) + 'dir1/dir2'
      FileHelper.touch_file(project.get_path(:data_files_dir) + 'dir1/dir2/test3')
      archive = project.create_temp_dir_archive(project.get_path(:data_files_dir))
      tmp_dir = Dir.mktmpdir
      `tar zxf #{archive} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir)
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it 'Packaging project' do
    begin
      project = make_project('Project 1')
      FileHelper.touch_file(project.get_path(:project_dir) + 'test1')
      FileHelper.touch_file(project.get_path(:project_dir) + 'test2')
      FileUtils.mkdir_p project.get_path(:project_dir) + 'dir1/dir2'
      FileHelper.touch_file(project.get_path(:project_dir) + 'dir1/dir2/test3')
      FileHelper.touch_file(project.get_path(:project_dir) + '.lock')
      FileHelper.touch_file(project.get_path(:project_dir) + '.dirt')
      FileHelper.touch_file(project.get_path(:project_dir) + 'tmp')
      project.generate_archives
      tmp_dir = Dir.mktmpdir
      `tar jxf #{project.get_path(:package_archive)} -C #{tmp_dir}`
      entries = FileHelper.get_file_list(tmp_dir + '/project')
      entries.include?(project.get_name(:db)).should be_true
      entries.include?(project.get_name(:ui_schema)).should be_true
      entries.include?(project.get_name(:ui_logic)).should be_true
      entries.include?(project.get_name(:settings)).should be_true
      entries.include?(project.get_name(:properties)).should be_true
      entries.include?(project.get_name(:validation_schema)).should be_true
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
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it 'Creating project initialise directory' do
    project = make_project('Project 1')
    File.exists?(project.get_path(:project_dir)).should be_true
    File.exists?(project.get_path(:tmp_dir)).should be_true
    File.exists?(project.get_path(:server_files_dir)).should be_true
    File.exists?(project.get_path(:app_files_dir)).should be_true
  end

  it 'Updating settings causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    project.settings_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project.package_dirty?.should be_true
  end

  it 'Updating database causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    project.db_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project.package_dirty?.should be_true
  end

  it 'Adding data files causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    FileUtils.touch project.get_path(:data_files_dir) + '/temp'
    project.package_dirty?.should be_true
  end

  it 'Updating data files causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    FileUtils.touch project.get_path(:data_files_dir) + '/temp'
    project.update_archives
    project.package_dirty?.should be_false
    project.data_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project.package_dirty?.should be_true
  end

  it 'Adding app files causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    FileUtils.touch project.get_path(:app_files_dir) + '/temp'
    project.package_dirty?.should be_true
  end

  it 'Updating app files causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    FileUtils.touch project.get_path(:app_files_dir) + '/temp'
    project.update_archives
    project.package_dirty?.should be_false
    project.app_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project.package_dirty?.should be_true
  end

  it 'Adding server files causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    FileUtils.touch project.get_path(:server_files_dir) + '/temp'
    project.package_dirty?.should be_true
  end

  it 'Updating server files causes package to rearchive' do
    project = make_project('Project 1')
    project.package_dirty?.should be_false
    FileUtils.touch project.get_path(:server_files_dir) + '/temp'
    project.update_archives
    project.package_dirty?.should be_false
    project.server_mgr.file_list.each {|f| FileUtils.touch f if File.exists? f}
    project.package_dirty?.should be_true
  end

end
