module DatabaseGenerator

  require 'sqlite3'

  def self.generate_database(file)
    db = SQLite3::Database.new(file)
    db.execute("create table empty( empty interger )")
    #db.enable_load_extension(true)
    #db.execute("select load_extension('#{spatialite_library}')")
    #db.execute("select initspatialmetadata()")
  end

  private
    def self.spatialite_library
      return 'libspatialite.dylib' if (/darwin/ =~ RUBY_PLATFORM) != nil
      return 'libspatialite.so'
    end

end
