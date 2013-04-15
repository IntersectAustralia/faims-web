module MD5Checksum

  def self.compute_checksum(filename)
    md5 = Digest::MD5.new
    File.open(filename) do |file|
      while line = file.gets
        md5.update(line)
      end
    end
    md5.hexdigest
  end

end