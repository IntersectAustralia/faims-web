require 'merge_daemon_helper'

MergeDaemon.init

loop do

  begin

    sleep 1 unless MergeDaemon.do_merge

  rescue SystemExit, Interrupt
    puts 'Merge daemon killed'
    exit(0)
  rescue Exception => e
    puts 'Error merging database'
    puts e.message
  end

end
