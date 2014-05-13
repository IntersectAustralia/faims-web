module TarHelper
  include SecurityHelper

  # TODO: Need to guard against command injection

  def self.untar(args, file, base_dir = nil)
    base_dir_str = "-C \"#{SecurityHelper.sanitize_file_path(base_dir)}\"" if base_dir

    `tar #{args} "#{SecurityHelper.sanitize_file_path(file)}" #{base_dir_str}; echo $?`
  end

  def self.tar(args, file, files, base_dir = nil, exclude_files = nil)
    file_str = (files.respond_to? :map) ?
        files.map { |f| "\"#{SecurityHelper.sanitize_relative_file_path(f)}\" " }.join :
        SecurityHelper.sanitize_relative_file_path(files)

    base_dir_str = "-C \"#{SecurityHelper.sanitize_file_path(base_dir)}\"" if base_dir

    exclude_file_str = exclude_files.map { |f| "--exclude=\"#{SecurityHelper.sanitize_relative_file_path(f)}\" " }.join if exclude_files

    `tar #{args} "#{SecurityHelper.sanitize_file_path(file)}" #{base_dir_str} #{file_str} #{exclude_file_str}; echo $?`
  end

end