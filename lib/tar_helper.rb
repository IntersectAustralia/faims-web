module TarHelper

  # TODO: Need to guard against command injection

  def self.untar(args, file, base_dir = nil)
    base_dir_str = "-C \"#{base_dir}\"" if base_dir

    result = `tar #{args} "#{file}" #{base_dir_str}; echo $?`
    result.to_i == 0
  end

  def self.tar(args, file, files, base_dir = nil, exclude_files = nil)
    file_str = (files.respond_to? :map) ? files.map { |f| "\"#{f}\" " }.join : files

    base_dir_str = "-C \"#{base_dir}\"" if base_dir

    exclude_file_str = exclude_files.map { |f| "--exclude=\"#{f}\" " }.join if exclude_files

    result = `tar #{args} "#{file}" #{base_dir_str} #{file_str} #{exclude_file_str}; echo $?`
    result.to_i == 0
  end

end