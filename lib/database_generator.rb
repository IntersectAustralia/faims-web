module DatabaseGenerator

  require 'sqlite3'

  def self.generate_database(file, xml)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("select initspatialmetadata()")
    content = File.read(Rails.root.join('lib', 'assets', 'init.sql'))
    content = content.gsub("\n", "")
    db.execute_batch(content)
    data_definition = XSLTParser.parse_data_schema(xml)
    data_definition = data_definition.gsub("\n", "");
    data_definition = data_definition.gsub("\t", "");
    db.execute_batch(data_definition)

  end

  def self.spatialite_library
    return 'libspatialite.dylib' if (/darwin/ =~ RUBY_PLATFORM) != nil
    return 'libspatialite.so'
  end

  def self.merge_database(toDB, fromDB)
    db = SQLite3::Database.new(toDB)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    content = <<EOF
attach database "?" as import;
insert into archentity select * from import.archentity where uuid || aenttimestamp not in (select uuid || aenttimestamp from archentity);
insert into aentvalue select * from import.aentvalue where uuid || valuetimestamp || attributeid not in (select uuid || valuetimestamp||attributeid from aentvalue);
insert into aentreln select * from import.aentreln where uuid || relationshipid || aentrelntimestamp not in (select uuid || relationshipid || aentrelntimestamp from aentreln);
insert into relationship select * from import.relationship where relationshipid || relntimestamp not in (select relationshipid || relntimestamp from relationship);
insert into relnvalue select * from import.relnvalue where relationshipid || relnvaluetimestamp || attributeid not in (select relationshipid || relnvaluetimestamp || attributeid from relnvalue);
detach database import;
EOF
    content = content.gsub("\n", "")
    content = content.gsub("?", fromDB)
    db.execute_batch(content)
  end

  def self.execute_query(file, query)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute(query)
  end

end
