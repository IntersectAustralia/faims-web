Dir.mkdir(Rails.application.config.server_uploads_directory) unless Rails.application.config.server_uploads_directory

class MergeDaemon

  # find project directory with given key
  def self.find_project_dir(project_key)
    Dir.entries(Rails.application.config.server_projects_directory).select do |dir|
      settings_file = Rails.application.config.server_projects_directory + '/' + dir + '/project.settings'
      if File.exists? settings_file
        settings = JSON.parse(File.read(settings_file))
        return dir if settings['key'] == project_key
      end
    end.first
  end

  def self.do_merge
    Dir.entries(Rails.application.config.server_uploads_directory).select { |f| not File.directory? f }.each do |db_file|

      # match file name for key and version
      match = /^(?<key>[^_]*)_v(?<version>.*)$/.match(db_file)
      next unless match # file is not valid

      key = match[:key]
      version = match[:version]

      # get projects directory
      project_dir = find_project_dir(key)
      next unless project_dir # key doesn't exist

      puts "Merging #{db_file}"

      project_database_file = Rails.application.config.server_projects_directory + '/' + project_dir + '/db.sqlite3'
      merge_database_file = Rails.application.config.server_uploads_directory + '/' + db_file

      # merge database
      DatabaseGenerator.merge_database(project_database_file, merge_database_file, version)

      FileUtils.rm_rf merge_database_file

      puts "Finished merging database"

      # archive project

      Project.find_by_key(key).update_archives

      puts "Archiving projects"

    end
  end

end

# process uploads
loop do

  begin

    MergeDaemon.do_merge

  rescue Exception => e
    puts "Error merging database"
    puts e
    exit(0)
  end

end