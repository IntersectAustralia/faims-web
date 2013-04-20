require 'spec_helper'
require Rails.root.to_s + '/lib/merge_daemon_helper'
require Rails.root.to_s + '/features/support/projects'
require Rails.root.to_s + '/spec/tools/helpers/database_generator_spec_helper'

describe MergeDaemon do

  describe "match file name" do
    it { MergeDaemon.match_file(SecureRandom.uuid + '_v0').should_not be_nil }
    it { MergeDaemon.match_file(SecureRandom.uuid + '_v1234').should_not be_nil }

    it { MergeDaemon.match_file(SecureRandom.uuid + '_v').should_not nil }
    it { MergeDaemon.match_file(SecureRandom.uuid + '_va12').should_not nil }
    it { MergeDaemon.match_file(SecureRandom.uuid + '_123').should_not nil }
    it { MergeDaemon.match_file(SecureRandom.uuid).should_not nil }
  end

  it "sort files by version" do
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

  it "should merge file uploads directory" do
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
    project = make_project "Project"

    # create uploads database
    filename = uploads_dir + '/' + project.key + '_v1'
    create_full_database(1, filename)

    # backup database
    FileUtils.cp filename, uploads_dir + '/temp.sqlite3'

    MergeDaemon.do_merge(uploads_dir, projects_dir)

    # check that upload is removed
    File.exists?(filename).should be_false

    # check that database is merged into project
    is_database_same(File.open(project.db_path), File.open(uploads_dir + '/temp.sqlite3')).should be_true
  end

  it "should not merge file uploads directory for bad names" do
    projects_dir = Rails.root.to_s + '/tmp/projects'
    tmp_dir = Rails.root.to_s + '/tmp'
	
	FileUtils.mkdir tmp_dir unless File.directory? tmp_dir
    uploads_dir = Rails.root.to_s + '/tmp/uploads'

    # cleanup projects and uploads directory
    FileUtils.rm_rf projects_dir if File.directory? projects_dir
    FileUtils.rm_rf uploads_dir if File.directory? uploads_dir

    FileUtils.mkdir projects_dir
    FileUtils.mkdir uploads_dir

    # create project
    project = make_project "Project"

    # create uploads database
    filename = uploads_dir + '/' + project.key
    create_full_database(1, filename)

    # backup database
    FileUtils.cp filename, uploads_dir + '/temp.sqlite3'

    MergeDaemon.do_merge(uploads_dir, projects_dir)

    # check that upload is removed
    File.exists?(filename).should be_true

    # check that database is merged into project
    is_database_same(File.open(project.db_path), File.open(uploads_dir + '/temp.sqlite3')).should be_false
  end

end
