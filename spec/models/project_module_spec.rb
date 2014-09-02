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

    # TODO add validations for data_schema, ui_schema, ui_logic, arch16n, validation_schema
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

  describe 'Scopes' do

    it 'should find created' do
      p1 = FactoryGirl.create(:project_module)
      p2 = FactoryGirl.create(:project_module)
      ProjectModule.all.to_set.should == [p1,p2].to_set
      p1.created = true
      p1.save
      ProjectModule.created.to_set.should == [p1].to_set
    end

    it 'should find deleted' do
      p1 = FactoryGirl.create(:project_module)
      p2 = FactoryGirl.create(:project_module)
      ProjectModule.all.to_set.should == [p1,p2].to_set
      p1.deleted = true
      p1.save
      ProjectModule.deleted.to_set.should == [p1].to_set
    end

    it 'should not find if deleted' do
      p1 = FactoryGirl.create(:project_module)
      p2 = FactoryGirl.create(:project_module)
      ProjectModule.all.to_set.should == [p1,p2].to_set
      p1.deleted = true
      p1.save
      ProjectModule.all.to_set.should == [p2].to_set
    end

    it 'should not find created if deleted' do
      p1 = FactoryGirl.create(:project_module)
      p2 = FactoryGirl.create(:project_module)
      ProjectModule.all.to_set.should == [p1,p2].to_set
      p1.created = true
      p1.deleted = true
      p1.save
      p2.created = true
      p2.save
      ProjectModule.created.to_set.should == [p2].to_set
    end
  end

  it 'should create project module directories' do
    project_module = make_project_module('Module 1')
    File.exists?(project_module.get_path(:project_module_dir)).should be_true
    File.exists?(project_module.get_path(:tmp_dir)).should be_true
    File.exists?(project_module.get_path(:server_files_dir)).should be_true
    File.exists?(project_module.get_path(:app_files_dir)).should be_true
  end

  it 'should create data archive for selected path' do
    begin
      project_module = make_project_module('Module 1')
      FileUtils.touch(project_module.get_path(:data_files_dir) + 'test1')
      FileUtils.touch(project_module.get_path(:data_files_dir) + 'test2')
      FileUtils.mkdir_p project_module.get_path(:data_files_dir) + 'dir1/dir2'
      FileUtils.touch(project_module.get_path(:data_files_dir) + 'dir1/dir2/test3')
      archive = project_module.create_data_archive(project_module.get_path(:data_files_dir))
      tmp_dir = Dir.mktmpdir
      `tar zxf #{archive} -C #{tmp_dir}`
      data_dir = Dir.glob(File.join(tmp_dir, 'data')).first
      entries = FileHelper.get_file_list(data_dir)
      entries.include?('test1').should be_true
      entries.include?('test2').should be_true
      entries.include?('dir1/dir2/test3').should be_true
    ensure
      FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  describe 'Packaging project module' do

    it 'should contain all project module files' do
      begin
        project_module = make_project_module('Module 1')
        sleep(1)
        FileUtils.touch(project_module.get_path(:project_module_dir) + 'test1')
        FileUtils.touch(project_module.get_path(:project_module_dir) + 'test2')
        FileUtils.mkdir_p project_module.get_path(:project_module_dir) + 'dir1/dir2'
        FileUtils.touch(project_module.get_path(:project_module_dir) + 'dir1/dir2/test3')
        FileUtils.touch(project_module.get_path(:project_module_dir) + '.lock')
        FileUtils.touch(project_module.get_path(:project_module_dir) + '.dirt')
        FileUtils.touch(project_module.get_path(:project_module_dir) + 'tmp')
        project_module.archive_project_module
        tmp_dir = Dir.mktmpdir
        `tar jxf #{project_module.get_path(:package_archive)} -C #{tmp_dir}`
        entries = FileHelper.get_file_list(File.join(tmp_dir, "Module_1"))
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

    it 'should archive if settings changed' do
      project_module = make_project_module('Module 1')
      project_module.archive_project_module
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      project_module.settings_mgr.absolute_file_list.each {|f| FileUtils.touch f}
      project_module.package_mgr.has_changes?.should be_true
    end

    it 'should archive if database changed' do
      project_module = make_project_module('Module 1')
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      project_module.db_mgr.absolute_file_list.each {|f| FileUtils.touch f}
      project_module.package_mgr.has_changes?.should be_true
    end

    it 'should archive if data files added' do
      project_module = make_project_module('Module 1')
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      FileUtils.touch project_module.get_path(:data_files_dir) + '/temp'
      project_module.package_mgr.has_changes?.should be_true
    end

    it 'should archive if data filed updated' do
      project_module = make_project_module('Module 1')
      project_module.package_mgr.has_changes?.should be_false
      FileUtils.touch project_module.get_path(:data_files_dir) + '/temp'
      project_module.archive_project_module
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      project_module.data_mgr.absolute_file_list.each {|f| FileUtils.touch f}
      project_module.package_mgr.has_changes?.should be_true
    end

    it 'should archive if app files added' do
      project_module = make_project_module('Module 1')
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      FileUtils.touch project_module.get_path(:app_files_dir) + '/temp'
      project_module.package_mgr.has_changes?.should be_true
    end

    it 'should archive if app files updated' do
      project_module = make_project_module('Module 1')
      project_module.package_mgr.has_changes?.should be_false
      FileUtils.touch project_module.get_path(:app_files_dir) + '/temp'
      project_module.archive_project_module
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      project_module.app_mgr.absolute_file_list.each {|f| FileUtils.touch f}
      project_module.package_mgr.has_changes?.should be_true
    end

    it 'should archive if server files added' do
      project_module = make_project_module('Module 1')
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      FileUtils.touch project_module.get_path(:server_files_dir) + '/temp'
      project_module.package_mgr.has_changes?.should be_true
    end

    it 'should archive if server files updated' do
      project_module = make_project_module('Module 1')
      project_module.package_mgr.has_changes?.should be_false
      FileUtils.touch project_module.get_path(:server_files_dir) + '/temp'
      project_module.archive_project_module
      project_module.package_mgr.has_changes?.should be_false
      sleep(1)
      project_module.server_mgr.absolute_file_list.each {|f| FileUtils.touch f}
      project_module.package_mgr.has_changes?.should be_true
    end

  end

  describe 'Cache File Info' do

    def file_info(name, file_path, project_module)
      {
          filename: file_path.to_s.gsub(project_module.get_path(:project_module_dir), ''),
          md5checksum: MD5Checksum.compute_checksum(file_path),
          size: File.size(file_path),
          type: name
      }
    end

    def compare_file_info(db_info, computed_info)
      db_info.size.should == computed_info.size
      db_info.each do |info1|
        info2 = computed_info.select { |c| c[:filename] == info1[:filename] }.first
        info1[:md5checksum].should == info2[:md5checksum]
        info1[:size].should == info2[:size]
        info1[:type].should == info2[:type]
      end
    end

    class FakeFile

      def initialize(path)
        @path = path
      end

      def path
        @path
      end

    end

    it 'should cache settings files when module created' do
      temp_dir = Dir.mktmpdir
      FileUtils.cp File.join(Rails.root.join('features/assets/sync_example'), 'data_schema.xml'), temp_dir
      FileUtils.cp File.join(Rails.root.join('features/assets/sync_example'), 'ui_schema.xml'), temp_dir
      FileUtils.cp File.join(Rails.root.join('features/assets/sync_example'), 'ui_logic.bsh'), temp_dir
      project_module = ProjectModule.create(:name => 'Module 1', :key => SecureRandom.uuid, :created => true)
      project_module.set_settings({name: 'Module 1'})
      project_module.create_project_module_from(temp_dir)

      computed_files = []
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:ui_schema), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:ui_logic), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:settings), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:properties), project_module)

      settings_files = project_module.db.get_files(ProjectModule::SETTINGS)
      compare_file_info(settings_files, computed_files)
    end

    it 'should cache settings files when module updated' do
      temp_dir = Dir.mktmpdir
      FileUtils.cp File.join(Rails.root.join('features/assets/sync_example'), 'data_schema.xml'), temp_dir
      FileUtils.cp File.join(Rails.root.join('features/assets/sync_example'), 'ui_schema.xml'), temp_dir
      FileUtils.cp File.join(Rails.root.join('features/assets/sync_example'), 'ui_logic.bsh'), temp_dir
      project_module = ProjectModule.create(:name => 'Module 1', :key => SecureRandom.uuid, :created => true)
      project_module.set_settings({name: 'Module 1'})
      project_module.create_project_module_from(temp_dir)

      # update settings files
      project_module.set_settings({name: 'Module 2'})
      FileUtils.cp File.join(Rails.root.join('features/assets/vocabulary'), 'ui_schema.xml'), temp_dir
      FileUtils.cp File.join(Rails.root.join('features/assets/vocabulary'), 'ui_logic.bsh'), temp_dir
      project_module.update_project_module_from(temp_dir)

      computed_files = []
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:ui_schema), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:ui_logic), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:settings), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:properties), project_module)

      settings_files = project_module.db.get_files(ProjectModule::SETTINGS)
      compare_file_info(settings_files, computed_files)
    end

    it 'should cache data files when added' do
      temp_dir = Dir.mktmpdir
      FileUtils.cp Rails.root.join('features/assets/garbage'), File.join(temp_dir, 'test')

      project_module = make_project_module('Module 1')
      project_module.db.get_files(ProjectModule::DATA).should be_empty

      project_module.add_data_file('test', FakeFile.new(File.join(temp_dir, 'test')))

      computed_files = []
      computed_files << file_info(ProjectModule::DATA, File.join(project_module.get_path(:data_files_dir), 'test'), project_module)

      data_files = project_module.db.get_files(ProjectModule::DATA)
      compare_file_info(data_files, computed_files)
    end

    it 'should remove cached data file when file removed' do
      temp_dir = Dir.mktmpdir
      FileUtils.cp Rails.root.join('features/assets/garbage'), File.join(temp_dir, 'test1')
      FileUtils.cp Rails.root.join('features/assets/garbage'), File.join(temp_dir, 'test2')

      project_module = make_project_module('Module 1')
      project_module.add_data_file('test1', FakeFile.new(File.join(temp_dir, 'test1')))
      project_module.add_data_file('test2', FakeFile.new(File.join(temp_dir, 'test2')))
      project_module.remove_data_file(File.join(project_module.get_path(:data_files_dir), 'test1'))

      computed_files = []
      computed_files << file_info(ProjectModule::DATA, File.join(project_module.get_path(:data_files_dir), 'test2'), project_module)

      data_files = project_module.db.get_files(ProjectModule::DATA)
      compare_file_info(data_files, computed_files)
    end

    it 'should remove cached data files when directory removed' do
      temp_dir = Dir.mktmpdir
      FileUtils.cp Rails.root.join('features/assets/garbage'), File.join(temp_dir, 'test1')
      FileUtils.cp Rails.root.join('features/assets/garbage'), File.join(temp_dir, 'test2')

      project_module = make_project_module('Module 1')
      project_module.add_data_dir('dir1')
      project_module.add_data_dir('dir2')
      project_module.add_data_file('dir1/test1', FakeFile.new(File.join(temp_dir, 'test1')))
      project_module.add_data_file('dir2/test2', FakeFile.new(File.join(temp_dir, 'test2')))
      project_module.remove_data_dir(File.join(project_module.get_path(:data_files_dir), 'dir1'))

      computed_files = []
      computed_files << file_info(ProjectModule::DATA, File.join(project_module.get_path(:data_files_dir), 'dir2/test2'), project_module)

      data_files = project_module.db.get_files(ProjectModule::DATA)
      compare_file_info(data_files, computed_files)
    end

    it 'should cache app data files when added' do
      temp_dir = Dir.mktmpdir
      FileUtils.cp Rails.root.join('features/assets/garbage'), File.join(temp_dir, 'test')

      project_module = make_project_module('Module 1')
      project_module.db.get_files(ProjectModule::APP).should be_empty

      project_module.add_app_file('test', FakeFile.new(File.join(temp_dir, 'test')))

      computed_files = []
      computed_files << file_info(ProjectModule::APP, File.join(project_module.get_path(:app_files_dir), 'test'), project_module)

      app_files = project_module.db.get_files(ProjectModule::APP)
      compare_file_info(app_files, computed_files)
    end

    it 'should cache server data files when added' do
      temp_dir = Dir.mktmpdir
      FileUtils.cp Rails.root.join('features/assets/garbage'), File.join(temp_dir, 'test')

      project_module = make_project_module('Module 1')
      project_module.db.get_files(ProjectModule::SERVER).should be_empty

      project_module.add_server_file('test', FakeFile.new(File.join(temp_dir, 'test')))

      computed_files = []
      computed_files << file_info(ProjectModule::SERVER, File.join(project_module.get_path(:server_files_dir), 'test'), project_module)

      server_files = project_module.db.get_files(ProjectModule::SERVER)
      compare_file_info(server_files, computed_files)
    end

    it 'should cache settings, data, app and server files when module uploaded' do
      temp_dir = Dir.mktmpdir

      project_module = make_project_module('Module 1')
      sleep(1)
      FileUtils.touch(File.join(project_module.get_path(:data_files_dir),'test'))
      FileUtils.touch(File.join(project_module.get_path(:app_files_dir),'test'))
      FileUtils.touch(File.join(project_module.get_path(:server_files_dir),'test'))
      project_module.archive_project_module

      # copy tarball
      FileUtils.cp project_module.get_path(:package_archive), File.join(temp_dir, 'module.tar.bz2')

      # remove module
      ProjectModule.unscoped.find_by_key(project_module.key).destroy

      # upload module
      project_module = ProjectModule.upload_project_module(File.join(temp_dir, 'module.tar.bz2'))

      # compare settings files
      computed_files = []
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:ui_schema), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:ui_logic), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:settings), project_module)
      computed_files << file_info(ProjectModule::SETTINGS, project_module.get_path(:properties), project_module)

      settings_files = project_module.db.get_files(ProjectModule::SETTINGS)
      compare_file_info(settings_files, computed_files)

      # compare data files
      computed_files = []
      computed_files << file_info(ProjectModule::DATA, File.join(project_module.get_path(:data_files_dir), 'test'), project_module)

      data_files = project_module.db.get_files(ProjectModule::DATA)
      compare_file_info(data_files, computed_files)

      # compare app files
      computed_files = []
      computed_files << file_info(ProjectModule::APP, File.join(project_module.get_path(:app_files_dir), 'test'), project_module)

      app_files = project_module.db.get_files(ProjectModule::APP)
      compare_file_info(app_files, computed_files)

      # compare server files
      computed_files = []
      computed_files << file_info(ProjectModule::SERVER, File.join(project_module.get_path(:server_files_dir), 'test'), project_module)

      server_files = project_module.db.get_files(ProjectModule::SERVER)
      compare_file_info(server_files, computed_files)
    end

  end


end
