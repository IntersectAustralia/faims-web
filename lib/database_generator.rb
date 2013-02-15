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

  def self.add_version(db, userid)
    db = SQLite3::Database.new(db)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    content = <<EOF
    insert into version (versionnum, versiontimestamp, userid) select count(*) + 1, CURRENT_TIMESTAMP, #{userid} from version;
EOF
    content = content.gsub("\n", "")
    db.execute_batch(content)
    db.execute("select count(*) from version").first.first
  end

  def self.merge_database(toDB, fromDB, version)
    db = SQLite3::Database.new(toDB)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    content = <<EOF
attach database "#{fromDB}" as import;
insert into archentity (uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, versionnum, geospatialcolumn) select uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, #{version}, geospatialcolumn from import.archentity where uuid || aenttimestamp not in (select uuid || aenttimestamp from archentity);
insert into aentvalue (uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, versionnum) select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, #{version} from import.aentvalue where uuid || valuetimestamp || attributeid not in (select uuid || valuetimestamp||attributeid from aentvalue);
insert into relationship (relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, versionnum, geospatialcolumn) select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, #{version}, geospatialcolumn from import.relationship where relationshipid || relntimestamp not in (select relationshipid || relntimestamp from relationship);
insert into relnvalue (relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, versionnum) select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, #{version} from import.relnvalue where relationshipid || relnvaluetimestamp || attributeid not in (select relationshipid || relnvaluetimestamp || attributeid from relnvalue);
insert into aentreln (uuid, relationshipid, participatesverb, aentrelntimestamp, versionnum) select uuid, relationshipid, participatesverb, aentrelntimestamp, #{version} from import.aentreln where uuid || relationshipid || aentrelntimestamp not in (select uuid || relationshipid || aentrelntimestamp from aentreln);
detach database import;
EOF
    content = content.gsub("\n", "")
    db.execute_batch(content)
  end

  def self.execute_query(file, query)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute(query)
  end

  def self.create_app_database(fromDB, toDB)
    db = SQLite3::Database.new(toDB)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("select initspatialmetadata()")

    db = SQLite3::Database.new(fromDB)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    content = <<EOF
attach database "#{toDB}" as export;
create table export.user as select * from user;
create table export.aenttype as select * from aenttype;
create table export.attributekey as select * from attributekey;
create table export.vocabulary as select * from vocabulary;
create table export.relntype as select * from relntype;
create table export.idealaent as select * from idealaent;
create table export.idealreln as select * from idealreln;
create table export.archentity as select uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, geospatialcolumn from archentity;
create table export.aentvalue as select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty from aentvalue;
create table export.relationship as select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, geospatialcolumn from relationship;
create table export.relnvalue as select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext from relnvalue;
create table export.aentreln as select uuid, relationshipid, participatesverb, aentrelntimestamp from aentreln;
detach database export;
EOF
    content = content.gsub("\n", "")
    db.execute_batch(content)
  end

end
