require 'merge_daemon_helper'

# make uploads directory
Dir.mkdir(Rails.application.config.server_uploads_directory) unless Rails.application.config.server_uploads_directory

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
