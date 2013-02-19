require 'spec_helper'
require Rails.root.to_s + '/lib/merge_daemon_helper'

describe MergeDaemon do

  describe "match file name" do
    it { MergeDaemon.match_file(SecureRandom.uuid + '_v0').should_not be_nil }
    it { MergeDaemon.match_file(SecureRandom.uuid + '_v1234').should_not be_nil }

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

end
