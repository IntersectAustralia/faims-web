class FileManager

  class TimeoutException < Exception
  end

  LOCK_TIMEOUT = 20

	def initialize(name, module_dir, base_dir)
		@name = name.gsub(/\s+/, '_')
    @module_dir = module_dir
    @base_dir = base_dir
		@timestamp_file = File.open(File.join(module_dir, ".#{name}"), File::CREAT)
    @files = []
    @dirs = []
    @ignore_files = []
    @ignore_dirs = []
  end

  def name
    @name
  end

  def module_dir
    @module_dir
  end

  def base_dir
    @base_dir
  end

  def timestamp_file
    @timestamp_file
  end

  def add_dir(full_dir_path)
    @dirs.push(full_dir_path)
  end

	def add_file(full_file_path)
		@files.push(full_file_path)
  end

  def ignore_dir(relative_dir_path)
    @ignore_dirs.push(relative_dir_path)
  end

  def ignore_file(relative_file_path)
    @ignore_files.push(full_file_path)
  end

  def file_list
    files = []
    @dirs.each do |d|
      path = Pathname.new(d).relative_path_from(Pathname.new(@base_dir)).to_s
      FileHelper.get_file_list(d, path == '.' ? nil : path).each do |f|
        files.push(f)
      end
    end
    @files.each do |f|
      path = Pathname.new(f).relative_path_from(Pathname.new(@base_dir)).to_s
      files.push(path)
    end
    files - ignore_file_list
  end

  def absolute_file_list
    file_list.map { |f| File.join(base_dir, f) }
  end

  def ignore_file_list
    files = []
    @ignore_dirs.each do |d|
      path = Pathname.new(d).relative_path_from(Pathname.new(@base_dir)).to_s
      FileHelper.get_file_list(d, path).each do |f|
        files.push(f)
      end
    end
    @ignore_files.each do |f|
      path = Pathname.new(f).relative_path_from(Pathname.new(@base_dir)).to_s
      files.push(path)
    end
    files
  end

  def init
    reset_changes
  end

	def has_changes?
    not file_list.select { |f| File.mtime("#{@base_dir}/#{f}") > File.mtime(@timestamp_file.path) }.empty?
	end

	def reset_changes
    FileUtils.touch @timestamp_file.path
    true
	end

	def with_shared_lock
    wait_for_lock(File::LOCK_SH)
    return yield
  ensure
    clear_lock
  end

  def with_exclusive_lock
    wait_for_lock(File::LOCK_EX)
    return yield
  ensure
    clear_lock
  end

  def wait_for_lock(lock)
    count = 0
    loop do
      break if acquire_lock(lock)
      count = count + 1
      break if count >= LOCK_TIMEOUT
      sleep 1
    end
    raise TimeoutException if count >= LOCK_TIMEOUT
  end

  def acquire_lock(lock)
    #p "locked(#{name})"
    @timestamp_file.flock(File::LOCK_NB | lock)
  end

  def clear_lock
    #p "unlocked(#{name})"
    @timestamp_file.flock(File::LOCK_UN)
  end

end