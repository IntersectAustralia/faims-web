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
    Dir.mkdir(Rails.application.config.server_upload_failures_directory) unless File.directory? Rails.application.config.server_upload_failures_directory
  end

  def self.do_merge(uploads_dir = nil)
    uploads_dir ||= Rails.application.config.server_uploads_directory
    upload_failures_dir ||= Rails.application.config.server_upload_failures_directory

    begin
      db_file_path = nil
      directory_files = Dir.entries(uploads_dir).select { |f| not File.directory? f }
      project_files = directory_files.select { |f| match_file(f) }
      sorted_files = sort_files_by_version(project_files)

      sorted_files.each do |db_file|
        db_file_path = uploads_dir + '/' + db_file

        # match file name for key and version
        match = match_file(db_file)
        raise Exception, "Error cannot find module key and version for file #{db_file}" unless match

        key = match[:key]
        version = match[:version]

        project_module = ProjectModule.find_by_key(key)
        raise Exception, "Error cannot find module with key #{key}" unless project_module

        puts "Merging #{db_file}"

        # merge database

        begin
          project_module.db.merge_database(db_file_path, version)
        rescue Exception => e
          puts e.to_s

          # move file to failures directory
          FileUtils.mv db_file_path, upload_failures_dir

          raise Exception, "Error cannot merge database file #{db_file}"
        end

        puts 'Finished merging database'
      end

      !sorted_files.empty?
    ensure
      FileUtils.rm_rf db_file_path if db_file_path
    end
  end

end
