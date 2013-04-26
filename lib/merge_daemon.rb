require 'merge_daemon_helper'

MergeDaemon.init

loop do

  begin

    MergeDaemon.do_merge

  rescue SystemExit, Interrupt
    puts 'Merge daemon killed'
    exit(0)
  rescue Exception => e
    puts 'Error merging database'
    puts e
  end

end
