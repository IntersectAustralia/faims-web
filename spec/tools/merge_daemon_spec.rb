require 'spec_helper'
require Rails.root.join('lib/merge_daemon_helper')
require Rails.root.join('features/support/projects')
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

  it 'should merge file uploads directory' do
    tmp_dir = Rails.root.to_s + '/tmp'
	FileUtils.mkdir tmp_dir unless File.directory? tmp_dir
    
	projects_dir = Rails.root.to_s + '/tmp/projects'
    uploads_dir = Rails.root.to_s + '/tmp/uploads'

    # cleanup projects and uploads directory
    FileUtils.rm_rf projects_dir if File.directory? projects_dir
    FileUtils.rm_rf uploads_dir if File.directory? uploads_dir
	
    FileUtils.mkdir projects_dir
    FileUtils.mkdir uploads_dir

    # create project
    project = make_project 'Project'

    # create uploads database
    filename = uploads_dir + '/' + project.key + '_v1'
    Database.generate_database(filename, Rails.root.join('spec/assets/data_schema.xml'))
    fill_database(SpatialiteDB.new(filename), 1)

    # backup database
    FileUtils.cp filename, uploads_dir + '/temp.sqlite3'

    MergeDaemon.do_merge(uploads_dir)

    # check that upload is removed
    File.exists?(filename).should be_false

    # check that database is merged into project
    is_database_same(project.db.spatialite_db, SpatialiteDB.new(uploads_dir + '/temp.sqlite3')).should be_true
  end

  it 'should not merge file uploads directory for bad names' do
    tmp_dir = Rails.root.to_s + '/tmp'
    FileUtils.mkdir tmp_dir unless File.directory? tmp_dir

    projects_dir = Rails.root.to_s + '/tmp/projects'
    uploads_dir = Rails.root.to_s + '/tmp/uploads'

    # cleanup projects and uploads directory
    FileUtils.rm_rf projects_dir if File.directory? projects_dir
    FileUtils.rm_rf uploads_dir if File.directory? uploads_dir

    FileUtils.mkdir projects_dir
    FileUtils.mkdir uploads_dir

    # create project
    project = make_project 'Project'

    # create uploads database
    filename = uploads_dir + '/' + project.key
    Database.generate_database(filename, Rails.root.join('spec/assets/data_schema.xml'))
    fill_database(SpatialiteDB.new(filename), 1)

    # backup database
    FileUtils.cp filename, uploads_dir + '/temp.sqlite3'

    MergeDaemon.do_merge(uploads_dir)

    # check that upload is removed
    File.exists?(filename).should be_true

    # check that database is merged into project
    is_database_same(project.db.spatialite_db, SpatialiteDB.new(uploads_dir + '/temp.sqlite3')).should be_false
  end

end
