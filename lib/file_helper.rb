module FileHelper
  def self.get_file_list(dir, base = '')
    list = []
    Dir.entries(dir).each do |file|
      next if file == '.' or file == '..'
      if File.directory? dir + '/' + file
        list = list.concat(FileHelper.get_file_list(dir + '/' + file, base + file + '/'))
      else
        list.push(base + file)
      end
    end
    list.sort
  end

  def self.copy_dir(from_dir, to_dir, exclude_files = [])
    Dir.entries(from_dir).each do |f|
      next if f == '.' or f == '..' or exclude_files.include? f
      file = from_dir + '/' + f
      if File.directory? file
        FileUtils.cp_r(file, to_dir)
      else
        FileUtils.cp(file, to_dir)
      end
    end
  end

  def self.touch_file(file)
    `touch #{file}`
  end

end