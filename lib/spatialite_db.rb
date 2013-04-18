require 'sqlite3'

class SpatialiteDB

  def initialize(file)
    @db = SQLite3::Database.new(file)
    @db.enable_load_extension(true)
    @db.execute("select load_extension('#{spatialite_library}')")
  end

  def execute(sql, *bind_vars)
    @db.execute(sql, bind_vars)
  end

  def execute_batch(sql, *bind_vars)
    @db.execute_batch(sql, bind_vars)
  end

  private

  def spatialite_library
    return 'libspatialite.dylib' if (/darwin/ =~ RUBY_PLATFORM) != nil
    return 'libspatialite.so'
  end
end