class MergeDaemon

  def self.match_file(file)
    /^(?<key>[^_]*)_v(?<version>\d*)$/.match(file)
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

  def self.do_merge
    begin
      db_file_path = nil
      directory_files = Dir.entries(Rails.application.config.server_uploads_directory).select { |f| not File.directory? f }
      project_files = directory_files.select { |f| match_file(f) }
      sorted_files = sort_files_by_version(project_files)
      sorted_files.each do |db_file|
        db_file_path = Rails.application.config.server_uploads_directory + '/' + db_file

        # match file name for key and version
        match = /^(?<key>[^_]*)_v(?<version>.*)$/.match(db_file)
        next unless match # file is not valid

        key = match[:key]
        version = match[:version]

        # get projects directory
        project_dir = key
        next unless project_dir # key doesn't exist

        puts "Merging #{db_file}"

        project_database_file = Rails.application.config.server_projects_directory + '/' + project_dir + '/db.sqlite3'
        merge_database_file = db_file_path

        # merge database
        DatabaseGenerator.merge_database(project_database_file, merge_database_file, version)

        # update project archives
        Project.update_archives_for(key)

        puts "Finished merging database"
      end
    ensure
      FileUtils.rm_rf db_file_path if db_file_path
    end
  end

end
