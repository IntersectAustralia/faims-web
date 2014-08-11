module SecurityHelper

  class SecurityException < Exception
  end

  def safe_root_join(path)
    return path unless path
    "#{Rails.root.to_s}/#{path}"
  end

  def safe_send_file(path, *args)
    sanitized_path = SecurityHelper.sanitize_file_path(path)
    send_file sanitized_path, *args
  end

  def safe_delete_directory(path)
    sanitized_path = SecurityHelper.sanitize_file_path(path)
    FileUtils.remove_entry_secure(sanitized_path, true) if File.directory? path
  end

  def safe_create_directory(path)
    sanitized_path = SecurityHelper.sanitize_file_path(path)
    FileUtils.mkdir(sanitized_path) unless File.directory? path
  end

  def safe_delete_file(path)
    sanitized_path = SecurityHelper.sanitize_file_path(path)
    FileUtils.remove_entry_secure(sanitized_path) if File.exists? path
  end

  def safe_file_read(path)
    sanitized_path = SecurityHelper.sanitize_file_path(path)
    File.read(sanitized_path)
  end

  def self.sanitize_file_path(path)
    return path if path.blank?
    raise SecurityException, "Potentially dangers file path \"#{path}\" found" if check_root_file_attack(path) or
        check_directory_traversal_attack(path)
    path
  end

  def self.sanitize_relative_file_path(path)
    return path if path.blank?
    raise SecurityException, "Potentially dangers file path \"#{path}\" found" if check_directory_traversal_attack(path)
    path
  end

  private

  ALLOWED_ROOT_PATHS = [Rails.root.to_s, '/tmp']

  def self.check_root_file_attack(path)
    ALLOWED_ROOT_PATHS.select { |root_path| /^#{Regexp.escape(root_path)}/ =~ path.to_s }.empty?
  end

  def self.check_directory_traversal_attack(path)
    /\.\./ =~ path.to_s or /%2e%2e/ =~ path.to_s
  end

  # TODO add more checks for allowed characters on file paths

end