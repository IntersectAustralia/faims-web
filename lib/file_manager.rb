class FileManager

	def initialize(name, base_dir, args, archive)
		@name = name.gsub(/\s+/, '_')
		@base_dir = base_dir
		@dirty_file = @base_dir + '.dirty_' + @name
		@lock_file = @base_dir + '.lock_' + @name
		@files = []
    @args = args
    @archive = archive
	end

	def add_dir(full_dir_path)
    fs = FileHelper.get_file_list(full_dir_path)
    fs.each do |file|
      add_file(File.join(full_dir_path, file), File.dirname(file))
    end
    file_list
	end

	def add_file(full_file_path, relative_base_dir = nil)
		f = { file: full_file_path, dir:relative_base_dir }
		@files.push(f) unless @files.include? f
	end

	def dirty?
		return true if File.exists? @dirty_file
    !@files.empty? and !File.exists? @archive
	end

	def make_dirt
		FileHelper.touch_file @dirty_file
		dirty?
	end

	def clean_dirt
		FileUtils.rm @dirty_file if dirty?
		!dirty?
	end

	def locked?
		File.exists? @lock_file
	end

	def with_lock
		wait_for_lock
		return yield
	ensure
		clear_lock
	end

	def wait_for_lock
		loop do
			break unless locked?
			sleep 1
    end
		FileHelper.touch_file @lock_file
		locked?
	end

	def clear_lock
		FileUtils.rm @lock_file if locked?
		!locked?
	end

	def file_list
		@files.map { |f| f[:file] }
	end

	def archive_list
		@files.map { |f| f[:dir] + '/' + File.basename(f[:file]) }
	end

	def update_archive
    if @files.empty?
      clean_dirt
      return true
    end
		return true unless dirty?
    FileUtils.rm @archive if File.exists? @archive
    tmp_dir = Dir.mktmpdir
    with_lock do
      @files.each do |f|
        next unless File.exists? f[:file]
        dir = f[:dir] ? f[:dir] + '/' : '/'
        FileUtils.mkdir_p(tmp_dir + '/' + dir) if f[:dir]
        file = tmp_dir + '/' + dir + File.basename(f[:file])
        FileUtils.cp_r(f[:file], file)
      end
      files = FileHelper.get_file_list(tmp_dir)
      TarHelper.tar(@args, @archive, files, tmp_dir)
      clean_dirt
    end
	ensure
		FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
  end

  def last_modified
    return File.ctime(@archive) if File.exists? @archive
    nil
  end

end