class ArchiveManager < FileManager

  def initialize(name, module_dir, base_dir, args, archive, archive_directory = nil)
    super(name, module_dir, base_dir)
    @base_dir
    @args = args
    @archive = archive
    @archive_directory = archive_directory
  end

  def has_changes?
    not File.exists? @archive or not file_list.select { |f| File.mtime("#{@base_dir}/#{f}") > File.mtime(@timestamp_file.path) }.empty?
  end

  def self.tmp_space
    stat = Sys::Filesystem.stat(Sys::Filesystem.mount_point("/tmp"))
    stat.block_size * stat.blocks_available
  end

  def self.module_space
    stat = Sys::Filesystem.stat(Sys::Filesystem.mount_point("/var/www/faims/"))
    stat.block_size * stat.blocks_available
  end

  def archive_space
    space = 0
    absolute_file_list.each do |f|
      next unless File.exists? f
      next if File.basename(f) =~ /^\./ # ignore dot files

      space += File.size f
    end
    space
  end

  def has_disk_space?
    space = archive_space
    if Sys::Filesystem.mount_point("/tmp") == Sys::Filesystem.mount_point("/var/www/faims/")
      tmp_space > space * 2
    else
      tmp_space > space && module_space > space
    end
  end

  # Note: archives will not include dot files
  def update_archive(compute_checksum = false)
    return true unless has_changes?

    FileUtils.remove_entry_secure @archive if File.exists? @archive

    tmp_dir = Dir.mktmpdir
    base_dir = @archive_directory ? File.join(tmp_dir, @archive_directory) : File.join(tmp_dir, 'archive')
    FileUtils.mkdir base_dir unless Dir.exists? base_dir

    with_exclusive_lock do
      absolute_file_list.each do |f|
        next unless File.exists? f
        next if File.basename(f) =~ /^\./ # ignore dot files

        rel_file = Pathname.new(f).relative_path_from(Pathname.new(@base_dir)).to_s
        rel_dir = Pathname.new(File.dirname(f)).relative_path_from(Pathname.new(@base_dir)).to_s

        FileUtils.mkdir_p(File.join(base_dir, rel_dir)) unless rel_dir == '.'
        FileUtils.cp_r(f, File.join(base_dir, rel_file))
      end

      # add version file
      File.open(File.join(base_dir, 'version'), 'w+') do |f|
        f.write(Rails.application.config.faims_version)
      end

      if compute_checksum
        hash_sum = {}

        FileHelper.get_file_list(base_dir).each do |f|
          hash_sum[f] = MD5Checksum.compute_checksum(File.join(base_dir, f))
        end

        File.open(File.join(base_dir, 'hash_sum'), 'w') do |file|
          file.write(hash_sum.to_json)
        end
      end

      success = TarHelper.tar(@args, @archive, tmp_dir, File.basename(base_dir))
      return false unless success

      reset_changes
    end
  ensure
    FileUtils.remove_entry_secure tmp_dir if tmp_dir and Dir.exists? tmp_dir
  end

end