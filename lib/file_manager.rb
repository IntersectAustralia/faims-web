class FileManager

	def initialize(name, base_dir, archive_dir)
		@name = name.gsub(/\s+/, '_')
		@base_dir = base_dir
		@archive_dir = archive_dir
		@dirty_file = @base_dir + '/.dirty_' + @name
		@lock_file = @base_dir + '/.lock_' + @name
		@files = []
	end

	def add_dir(dir)
	end

	def add_file(full_file_path, relative_base_dir)
		f = { file: full_file_path, dir:relative_base_dir }
		@files.push() unless @files.include? f
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
		loop
			break unless locked?
			sleep 1
		end
		FileHelper.touch_file @locked_file
		locked?
	end

	def clear_lock
		FileUtils.rm @locked_file if locked?
		!locked?
	end

	def file_list
		@files.map { |f| f[:file] }
	end

	def archive_list
		@files.map { |f| f[:dir] + '/' + File.basename(f[:file]) }
	end

	def update_archive
		return true if @files.empty?
		return true unless dirty?
		tmp_dir = Dir.mktmpdir
		@files.each do |f|
			next unless File.exists? f[:file]
			FileUtils.cp(f[:file], f[:dir] + '/' + File.basename(f[:file]))
		end
		clean_dirt
	ensure
		FileUtils.rm tmp_dir if File.directory? tmp_dir
	end

end