# make uploads directory
Dir.mkdir(Rails.application.config.server_uploads_directory) unless Rails.application.config.server_uploads_directory

class MergeDaemon

  def self.do_merge
    begin
      db_file_path = nil
      Dir.entries(Rails.application.config.server_uploads_directory).select { |f| not File.directory? f }.each do |db_file|
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
        
        FileUtils.rm_rf merge_database_file

        puts "Finished merging database"
      end
    ensure
      FileUtils.rm_rf db_file_path if db_file_path
    end
  end

end

# process uploads
loop do

  begin

    MergeDaemon.do_merge

  rescue SystemExit, Interrupt
    puts "Merge daemon killed"
    exit(0)
  rescue Exception => e
    puts "Error merging database"
    puts e
  end

end
