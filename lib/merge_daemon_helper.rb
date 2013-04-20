require Rails.root.join('config/environment')

class MergeDaemon

  def self.match_file(file)
    /^(?<key>[^_]+)_v(?<version>\d+)$/.match(file)
  end

  def self.sort_files_by_version(files)
    # sort files by version
    sorted_files = files.sort do |a, b|
      ma = match_file a
      mb = match_file b
      s = 1
      s = -1 if ma[:version] < mb[:version]
      s = 0 if ma[:version] == mb[:version]
      s
    end
    sorted_files
  end

  def self.init
    # make uploads directory
    Dir.mkdir(Rails.application.config.server_uploads_directory) unless File.directory? Rails.application.config.server_uploads_directory
  end

  def self.do_merge(uploads_dir = nil, projects_dir = nil)
    uploads_dir ||= Rails.application.config.server_uploads_directory
    projects_dir ||= Rails.application.config.server_projects_directory

    begin
      db_file_path = nil
      directory_files = Dir.entries(uploads_dir).select { |f| not File.directory? f }
      project_files = directory_files.select { |f| match_file(f) }
      sorted_files = sort_files_by_version(project_files)
      sorted_files.each do |db_file|
        db_file_path = uploads_dir + '/' + db_file

        # match file name for key and version
        match = match_file(db_file)
        raise Exception unless match

        key = match[:key]
        version = match[:version]

        # get projects directory
        project_key = key
        raise Exception unless project_key # key doesn't exist

        project = Project.find_by_key(project_key)

        puts "Merging #{db_file}"

        # merge database
        project.db.merge_database(db_file_path, version)

        puts 'Finished merging database'
      end
    ensure
      FileUtils.rm_rf db_file_path if db_file_path
    end
  end

end
