require 'spec_helper'
require Rails.root.join('lib/merge_daemon_helper')
require Rails.root.join('features/support/project_modules')
require Rails.root.join('spec/tools/helpers/database_generator_spec_helper')

describe MergeDaemon do

  describe 'match file name' do
    it { MergeDaemon.match_file(SecureRandom.uuid + '_v0').should_not be_nil }
    it { MergeDaemon.match_file(SecureRandom.uuid + '_v1234').should_not be_nil }

    it { MergeDaemon.match_file(SecureRandom.uuid + '_v').should_not nil }
    it { MergeDaemon.match_file(SecureRandom.uuid + '_va12').should_not nil }
    it { MergeDaemon.match_file(SecureRandom.uuid + '_123').should_not nil }
    it { MergeDaemon.match_file(SecureRandom.uuid).should_not nil }
  end

  it 'sort files by version' do
    a = SecureRandom.uuid
    b = SecureRandom.uuid
    if a > b
      tmp = a
      a = b
      b = tmp
    end
    files = [a + '_v4', b + '_v1', b + '_v3', a + '_v2']
    MergeDaemon.sort_files_by_version(files).should == [b + '_v1', a + '_v2', b + '_v3', a + '_v4']
  end

  it 'should merge file uploads directory', :ignore_jenkins => true do
    tmp_dir = Rails.root.to_s + '/tmp'
	  FileUtils.mkdir tmp_dir unless File.directory? tmp_dir
    
	  project_modules_dir = Rails.root.to_s + '/tmp/project_modules'
    uploads_dir = Rails.root.to_s + '/tmp/uploads'

    # cleanup project_modules and uploads directory
    FileUtils.remove_entry_secure project_modules_dir if File.directory? project_modules_dir
    FileUtils.remove_entry_secure uploads_dir if File.directory? uploads_dir
	
    FileUtils.mkdir project_modules_dir
    FileUtils.mkdir uploads_dir

    # create project_module
    project_module = make_project_module 'Module 1'

    # create uploads database
    filename = uploads_dir + '/' + project_module.key + '_v1'
    Database.generate_database(filename, Rails.root.join('spec/assets/data_schema.xml'))
    fill_database(SpatialiteDB.new(filename), 1)

    # backup database
    FileUtils.cp filename, uploads_dir + '/temp.sqlite3'

    MergeDaemon.do_merge(uploads_dir)

    # check that upload is removed
    File.exists?(filename).should be_false

    # check that database is merged into project_module
    is_database_same(project_module.db.spatialite_db, SpatialiteDB.new(uploads_dir + '/temp.sqlite3')).should be_true
  end

  it 'should not merge file uploads directory for bad names', :ignore_jenkins => true do
    tmp_dir = Rails.root.to_s + '/tmp'
    FileUtils.mkdir tmp_dir unless File.directory? tmp_dir

    project_modules_dir = Rails.root.to_s + '/tmp/project_modules'
    uploads_dir = Rails.root.to_s + '/tmp/uploads'

    # cleanup project_modules and uploads directory
    FileUtils.remove_entry_secure project_modules_dir if File.directory? project_modules_dir
    FileUtils.remove_entry_secure uploads_dir if File.directory? uploads_dir

    FileUtils.mkdir project_modules_dir
    FileUtils.mkdir uploads_dir

    # create project_module
    project_module = make_project_module 'Module 1'

    # create uploads database
    filename = uploads_dir + '/' + project_module.key
    Database.generate_database(filename, Rails.root.join('spec/assets/data_schema.xml'))
    fill_database(SpatialiteDB.new(filename), 1)

    # backup database
    FileUtils.cp filename, uploads_dir + '/temp.sqlite3'

    MergeDaemon.do_merge(uploads_dir)

    # check that upload is removed
    File.exists?(filename).should be_true

    # check that database is merged into project_module
    is_database_same(project_module.db.spatialite_db, SpatialiteDB.new(uploads_dir + '/temp.sqlite3')).should be_false
  end

end
