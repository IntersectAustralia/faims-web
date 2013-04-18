module TarHelper

  def self.untar(args, file, base_dir = nil)
    base_dir_str = "-C #{base_dir}" if base_dir
    `tar #{args} #{file} #{base_dir_str}`
  end

  def self.tar(args, file, files, base_dir = nil, exclude_files = nil)
    file_str = (files.respond_to? :map) ? files.map { |f| "#{f} " }.join : files
    base_dir_str = "-C #{base_dir}" if base_dir
    exclude_file_str = exclude_files.map { |f| "--exclude=#{f} " }.join if exclude_files
    `tar #{args} #{file} #{base_dir_str} #{file_str} #{exclude_file_str}`
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