class FileManager

	def initialize(name, base_dir)
		@name = name.gsub(/\s+/, '_')
		@base_dir = base_dir
		@dirty_file = @base_dir + '.dirty_' + @name
		@lock_file = @base_dir + '.lock_' + @name
		@files = []
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
		File.exists? @dirty_file
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

	def update_archive(args, path)
		return true if @files.empty?
		return true unless dirty?
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
      TarHelper.tar(args, path, files, tmp_dir)
      clean_dirt
    end
	ensure
		FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
	end

end