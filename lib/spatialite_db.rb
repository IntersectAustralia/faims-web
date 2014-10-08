require 'sqlite3'

class SpatialiteDB

  def initialize(file)
    @path = file
    @db = SQLite3::Database.new(file)
    @db.enable_load_extension(true)
    @db.execute("select load_extension('#{SpatialiteDB.spatialite_library}')")
  end

  def load_functions
    @db.create_function('format', -1) do |func, *args|
      if args.empty? or args.size < 1
        func.result = nil
      else
        if args[0].nil?
          func.result = args[1..-1].join(', ')
        else
          func.result = StringFormatter.new(args[0]).pre_compute.evaluate(args[1..-1])
        end
      end
    end
  end

  def transaction
    @db.transaction do |db|
      return yield db
    end
  end

  def get_first_row(sql, *bind_vars)
    @db.get_first_row(sql, bind_vars)
  end

  def get_first_value(sql, *bind_vars)
    @db.get_first_value(sql, bind_vars)
  end

  def last_insert_row_id
    @db.last_insert_row_id
  end

  def execute(sql, *bind_vars)
    @db.execute(sql, bind_vars)
  end

  def execute_batch(sql, *bind_vars)
    @db.execute_batch(sql, bind_vars)
  end

  def path
    @path
  end

  def self.library_exists?(lib = nil)
    lib ||= spatialite_library
    temp_file = Tempfile.new('tmpdb.sqlite3')
    db = SQLite3::Database.new(temp_file.path)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{lib}')")
    true
  rescue
    false
  ensure
    temp_file.unlink
  end

  private

  def self.spatialite_library
    return 'libspatialite.dylib' if (/darwin/ =~ RUBY_PLATFORM) != nil
    return 'libspatialite.so'
  end
end