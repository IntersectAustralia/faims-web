require 'tempfile'

def create_empty_database(filename = nil)
  if filename
    file = File.new(filename, 'w+')
  else
    file = Tempfile.new('db')
  end
  Database.generate_database(file.path, "#{Rails.root}/spec/assets/data_schema.xml")
  file.close
  file
end

def create_full_database(version = nil, filename = nil, index = nil)
  version ||= 1 # default version

  if filename
    file = File.new(filename, 'w+')
  else
    file = Tempfile.new('db')
  end

  Database.generate_database(file.path, "#{Rails.root}/spec/assets/data_schema.xml")

  s = index ? index : 0
  n = s + 5
  (s..n).each do |i|
      Database.execute_query(file.path, "INSERT INTO ArchEntity (uuid, userid, AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, AEntTimestamp, VersionNum) " +
        "VALUES (cast('#{i}' as integer), '0', 'ExcavationUnitStructure', 'GEOMETRYCOLLECTION', GeomFromText('GEOMETRYCOLLECTION(POINT(0 0))', 4326), CURRENT_TIMESTAMP, #{version});")

    (s..n).each do |j|
      Database.execute_query(file.path, "INSERT INTO AEntValue (uuid, VocabID, AttributeID, Measure, FreeText, Certainty, ValueTimestamp, VersionNum) " +
          "SELECT cast('#{i*n + j}' as integer), '0', attributeID, '0', 'Text', '0', CURRENT_TIMESTAMP, #{version} " +
          "FROM AttributeKey " +
          "WHERE attributeName = 'Excavator' COLLATE NOCASE;")
    end
  end

  (s..n).each do |i|
    Database.execute_query(file.path, "INSERT INTO Relationship (RelationshipID, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, RelnTimestamp, VersionNum) " +
        "VALUES (cast('#{i}' as integer), '0', 'Area', 'GEOMETRYCOLLECTION', GeomFromText('GEOMETRYCOLLECTION(POINT(0 0))', 4326), CURRENT_TIMESTAMP, #{version});")

    (s..n).each do |j|
      Database.execute_query(file.path, "INSERT INTO RelnValue (RelationshipID, VocabID, AttributeID, FreeText, Certainty, RelnValueTimestamp, VersionNum) " +
          "SELECT cast('#{i*n + j}' as integer), '0', attributeId, 'Text', '1.0', CURRENT_TIMESTAMP, #{version} " +
          "FROM AttributeKey " +
          "WHERE attributeName = 'Excavator' COLLATE NOCASE;")
    end
  end

  (s..n).each do |i|
    Database.execute_query(file.path, "INSERT INTO AEntReln (UUID, RelationshipID, ParticipatesVerb, AEntRelnTimestamp, VersionNum) " +
                                        "VALUES ('#{i}', '#{i}', '', CURRENT_TIMESTAMP, #{version});")
  end
  file.close
  file
end

def backup_database(db)
  file = Tempfile.new('copy')
  FileUtils.copy_file(db.path, file.path)
  file.close
  file
end

def is_database_empty(db)
  return false if Database.execute_query(db.path, "select * from archentity;") != []
  return false if Database.execute_query(db.path, "select * from aentvalue;") != []
  return false if Database.execute_query(db.path, "select * from relationship;") != []
  return false if Database.execute_query(db.path, "select * from relnvalue;") != []
  return false if Database.execute_query(db.path, "select * from aentreln;") != []
  return true
end

def is_database_same(db1, db2)
  return false if Database.execute_query(db1.path, "select * from archentity;") !=
      Database.execute_query(db2.path, "select * from archentity;")
  return false if Database.execute_query(db1.path, "select * from aentvalue;") !=
      Database.execute_query(db2.path, "select * from aentvalue;")
  return false if Database.execute_query(db1.path, "select * from relationship;") !=
      Database.execute_query(db2.path, "select * from relationship;")
  return false if Database.execute_query(db1.path, "select * from relnvalue;") !=
      Database.execute_query(db2.path, "select * from relnvalue;")
  return false if Database.execute_query(db1.path, "select * from aentreln;") !=
      Database.execute_query(db2.path, "select * from aentreln;")
  return true
end

def is_version_database_same(db1, db2, version)
  return false if Database.execute_query(db1.path, "select uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, geospatialcolumn from archentity where versionnum = #{version};") !=
      Database.execute_query(db2.path, "select uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, geospatialcolumn from archentity;")
  return false if Database.execute_query(db1.path, "select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty from aentvalue where versionnum = #{version};") !=
      Database.execute_query(db2.path, "select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty from aentvalue;")
  return false if Database.execute_query(db1.path, "select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, geospatialcolumn from relationship where versionnum = #{version};") !=
      Database.execute_query(db2.path, "select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, geospatialcolumn from relationship;")
  return false if Database.execute_query(db1.path, "select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, certainty from relnvalue where versionnum = #{version};") !=
      Database.execute_query(db2.path, "select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, certainty from relnvalue;")
  return false if Database.execute_query(db1.path, "select uuid, relationshipid, participatesverb, aentrelntimestamp from aentreln where versionnum = #{version};") !=
      Database.execute_query(db2.path, "select uuid, relationshipid, participatesverb, aentrelntimestamp from aentreln;")
  return true
end

def is_database_merged(db, db1, db2)
  return false unless is_table_merged(db, db1, db2, "archentity")
  return false unless is_table_merged(db, db1, db2, "aentvalue")
  return false unless is_table_merged(db, db1, db2, "relationship")
  return false unless is_table_merged(db, db1, db2, "relnvalue")
  return false unless is_table_merged(db, db1, db2, "aentreln")
  return true
end

def is_table_merged(db, db1, db2, table)
  expected_rows = Database.execute_query(db.path, "select * from #{table};")

  rows1 = Database.execute_query(db1.path, "select * from #{table};")
  rows2 = Database.execute_query(db2.path, "select * from #{table};")

  return expected_rows == merge_rows(rows1, rows2)
end

def merge_rows(rows1, rows2)
  rows1.concat(rows2.select { |x| !rows1.include? x  })
end