class ArchiveManager < FileManager

  def initialize(name, module_dir, base_dir, args, archive, archive_directory = nil)
    super(name, module_dir, base_dir)
    @base_dir
    @args = args
    @archive = archive
    @archive_directory = archive_directory
  end

  # Note: archives will not include dot files
  def update_archive(compute_checksum = false)
    return true unless has_changes?

    FileUtils.remove_entry_secure @archive if File.exists? @archive

    tmp_dir = Dir.mktmpdir
    base_dir = @archive_directory ? File.join(tmp_dir, @archive_directory) : tmp_dir
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

      if compute_checksum
        hash_sum = {}

        FileHelper.get_file_list(base_dir).each do |f|
          hash_sum[f] = MD5Checksum.compute_checksum(File.join(base_dir, f))
        end

        File.open(File.join(base_dir, 'hash_sum'), 'w') do |file|
          file.write(hash_sum.to_json)
        end
      end

      files = FileHelper.get_file_list(tmp_dir)
      success = TarHelper.tar(@args, @archive, files, tmp_dir)
      return false unless success

      reset_changes
    end
  ensure
    FileUtils.remove_entry_secure tmp_dir if tmp_dir and Dir.exists? tmp_dir
  end

end