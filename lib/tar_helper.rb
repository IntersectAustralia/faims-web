module TarHelper

  def self.untar(args, file, base_dir = nil)
    base_dir_str = "-C \"#{base_dir}\"" if base_dir
    `tar #{args} "#{file}" #{base_dir_str}`
  end

  def self.tar(args, file, files, base_dir = nil, exclude_files = nil)
    file_str = (files.respond_to? :map) ? files.map { |f| "\"#{f}\" " }.join : files
    base_dir_str = "-C \"#{base_dir}\"" if base_dir
    exclude_file_str = exclude_files.map { |f| "--exclude=\"#{f}\" " }.join if exclude_files
    `tar #{args} "#{file}" #{base_dir_str} #{file_str} #{exclude_file_str}`
  end

end