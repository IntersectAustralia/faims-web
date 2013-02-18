ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require Rails.root.to_s + "/config/environment"

Dir.mkdir(Rails.application.config.server_uploads_directory) unless Rails.application.config.server_uploads_directory

class MergeDaemon

  def self.do_merge
    Dir.entries(Rails.application.config.server_uploads_directory).select { |f| not File.directory? f }.each do |db_file|

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
      merge_database_file = Rails.application.config.server_uploads_directory + '/' + db_file

      # merge database
      DatabaseGenerator.merge_database(project_database_file, merge_database_file, version)

      # update project archives
      Project.update_archives_for(key)

      FileUtils.rm_rf merge_database_file

      puts "Finished merging database"

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