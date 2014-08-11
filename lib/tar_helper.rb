module TarHelper

  # TODO: Need to guard against command injection

  def self.untar(args, tar_file, base_dir)
    `tar #{args} "#{tar_file}" -C "#{base_dir}"`
    $?.success?
  end

  def self.tar(args, tar_file, base_dir, *files)
    `tar #{args} "#{tar_file}" -C "#{base_dir}" #{files.map {|f| "#{f}"}.join(' ')}`
    $?.success?
  end

end