require "thor"

PROJ = "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"

class SHPExporter

  def self.export_dir(dirname)
    if !Dir.exists? dirname
      puts "ERROR: directory #{dirname} does not exist"
      return
    end
    dirname = dirname + '/' unless dirname[-1] == '/'
    `rm -f #{dirname}*_out.*`
    Dir.glob("#{dirname}*.shp") do |shp_file|
      export_file(dirname, shp_file)
    end
  end

  def self.export_file(dirname, filename)
    if !File.exists? filename or filename == "."
      puts "ERROR: file #{filename} does not exist"
      return
    end
    puts "Exporting #{filename}"
    `rm -f #{File.basename(filename, ".*")}_out.*`
    `ogr2ogr -t_srs "#{PROJ}" #{dirname + File.basename(filename, ".*") + "_out.shp"} #{filename}`
  end

end

class SHPExporterThor < Thor
  desc "export", "export and transform shape files"
  method_option :dir, :aliases => "-d",
                :desc => "export directory"
  method_option :quite, :aliases => "-q",
                :desc => "silent mode"
  def export(filename)
    if options[:dir]
      SHPExporter.export_dir(filename)
    else
      SHPExporter.export_file("./", filename)
    end
  end

end

if __FILE__ == $0
  SHPExporterThor.start(ARGV)
end
