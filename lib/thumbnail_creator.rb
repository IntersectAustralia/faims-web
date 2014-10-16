class ThumbnailCreator

  class << self
    def create_thumbnail_for_file(file)
      thumbnail_file = generate_thumbnail_filename(file)
      temp_file = Tempfile.new(['thumbnail', '.jpg'])

      if is_image? file
       `convert "#{file}" -rotate 90 -thumbnail #{thumbnail_size}% "#{temp_file.path}"`
        if $?.success?
          FileUtils.mv temp_file, thumbnail_file
          return thumbnail_file
        end
      else
        `convert "#{file}"[1] -rotate 90 -thumbnail #{thumbnail_size}% "#{temp_file.path}"`
        if $?.success?
          FileUtils.mv temp_file, thumbnail_file
          return thumbnail_file
        end
      end

      nil
    end

    def thumbnail_size
      Rails.application.config.thumbnail_size
    end

    def generate_thumbnail_filename(file)
      name = File.basename(file.gsub('.original', ''), '.*')
      dir = File.dirname(file)
      File.join(dir, "#{name}.thumbnail.jpg")
    end

    def is_image?(file)
      return (`file -b -i #{file}` =~ /video/).nil?
    end
  end

end