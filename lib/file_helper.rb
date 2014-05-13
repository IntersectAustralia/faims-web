module FileHelper

  def self.get_file_list(dir, base = nil)
    list = []
    Dir.entries(dir).each do |file|
      next if file == '.' or file == '..'
      if File.directory? File.join(dir, file)
        list = list.concat(FileHelper.get_file_list(File.join(dir, file), base.nil? ? file : File.join(base, file)))
      else
        list.push(base.nil? ? file : File.join(base, file))
      end
    end
    list.sort
  end

  def self.get_file_list_by_dir(dir, base = '.')
    list = []
    Dir.entries(dir).each do |file|
      next if file == '.' or file == '..'
      if File.directory? File.join(dir, file)
        sub_list = FileHelper.get_file_list_by_dir(File.join(dir, file), File.join(base, file))
        list.push(sub_list)
      else
        list.push(file)
      end
    end
    {base => list}
  end

  def self.copy_dir(from_dir, to_dir, exclude_files = [])
    Dir.entries(from_dir).each do |f|
      next if f == '.' or f == '..' or exclude_files.include? f
      file = File.join(from_dir, f)
      if File.directory? file
        FileUtils.cp_r(file, to_dir)
      else
        FileUtils.cp(file, to_dir)
      end
    end
  end

  def self.group_by_dir(files)
    dirs = {}

    files.each do |f|
      dirs[File.dirname(f)] ||= []
      dirs[File.dirname(f)].push(f)
    end

    dirs
  end

  def self.compare_paths(dir1, dir2)
    d1 = File.join(File.dirname(dir1), File.basename(dir1))
    d2 = File.join(File.dirname(dir2), File.basename(dir2))
    d1 == d2
  end

end