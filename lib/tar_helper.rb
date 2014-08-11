module TarHelper

  # TODO: Need to guard against command injection

  def self.untar(args, tar_file, base_dir)
    `tar #{args} "#{tar_file}" -C "#{base_dir}"`
    $?.success?
  end

  def self.tar(args, tar_file, file_or_dir)
    `tar #{args} "#{tar_file}" -C "#{File.dirname(file_or_dir)}" "#{File.basename(file_or_dir)}"`
    $?.success?
  end

end