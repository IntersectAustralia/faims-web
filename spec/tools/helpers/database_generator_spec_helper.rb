require 'tempfile'

def create_empty_database
  file = Tempfile.new('db')
  DatabaseGenerator.generate_database(file.path, "#{Rails.root}/spec/assets/data_schema.xml")
  file.close
  file
end

def create_full_database
  file = Tempfile.new('db')
  DatabaseGenerator.generate_database(file.path, "#{Rails.root}/spec/assets/data_schema.xml")

  n = 5
  (0..n).each do |i|
    DatabaseGenerator.execute_query(file.path, "INSERT INTO ArchEntity (uuid, userid, AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, AEntTimestamp) " +
        "VALUES (cast('#{i}' as integer), '0', 'ExcavationUnitStructure', 'GEOMETRYCOLLECTION', GeomFromText('GEOMETRYCOLLECTION(POINT(0 0))', 4326), CURRENT_TIMESTAMP);")

    (0..n).each do |j|
      DatabaseGenerator.execute_query(file.path, "INSERT INTO AEntValue (uuid, VocabID, AttributeID, Measure, FreeText, Certainty, ValueTimestamp) " +
          "SELECT cast('#{i*n + j}' as integer), '0', attributeID, '0', 'Text', '0', CURRENT_TIMESTAMP " +
          "FROM AttributeKey " +
          "WHERE attributeName = 'Excavator' COLLATE NOCASE;")
    end
  end

  (0..n).each do |i|
    DatabaseGenerator.execute_query(file.path, "INSERT INTO Relationship (RelationshipID, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, RelnTimestamp) " +
        "VALUES (cast('#{i}' as integer), '0', 'Area', 'GEOMETRYCOLLECTION', GeomFromText('GEOMETRYCOLLECTION(POINT(0 0))', 4326), CURRENT_TIMESTAMP);")

    (0..n).each do |j|
      DatabaseGenerator.execute_query(file.path, "INSERT INTO RelnValue (RelationshipID, VocabID, AttributeID, FreeText, RelnValueTimestamp) " +
          "SELECT cast('#{i*n + j}' as integer), '0', attributeId, 'Text', CURRENT_TIMESTAMP " +
          "FROM AttributeKey " +
          "WHERE attributeName = 'Excavator' COLLATE NOCASE;")
    end
  end

  (0..n).each do |i|
    DatabaseGenerator.execute_query(file.path, "INSERT INTO AEntReln (UUID, RelationshipID, ParticipatesVerb, AEntRelnTimestamp) " +
                                        "VALUES ('#{rand(1000)}', '#{rand(1000)}', '', CURRENT_TIMESTAMP);")
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
  return false if DatabaseGenerator.execute_query(db.path, "select * from archentity;") != []
  return false if DatabaseGenerator.execute_query(db.path, "select * from aentvalue;") != []
  return false if DatabaseGenerator.execute_query(db.path, "select * from relationship;") != []
  return false if DatabaseGenerator.execute_query(db.path, "select * from relnvalue;") != []
  return false if DatabaseGenerator.execute_query(db.path, "select * from aentreln;") != []
  return true
end

def is_database_same(db1, db2)
  return false if DatabaseGenerator.execute_query(db1.path, "select * from archentity;") !=
      DatabaseGenerator.execute_query(db2.path, "select * from archentity;")
  return false if DatabaseGenerator.execute_query(db1.path, "select * from aentvalue;") !=
      DatabaseGenerator.execute_query(db2.path, "select * from aentvalue;")
  return false if DatabaseGenerator.execute_query(db1.path, "select * from relationship;") !=
      DatabaseGenerator.execute_query(db2.path, "select * from relationship;")
  return false if DatabaseGenerator.execute_query(db1.path, "select * from relnvalue;") !=
      DatabaseGenerator.execute_query(db2.path, "select * from relnvalue;")
  return false if DatabaseGenerator.execute_query(db1.path, "select * from aentreln;") !=
      DatabaseGenerator.execute_query(db2.path, "select * from aentreln;")
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
  expected_rows = DatabaseGenerator.execute_query(db.path, "select * from #{table};")

  rows1 = DatabaseGenerator.execute_query(db1.path, "select * from #{table};")
  rows2 = DatabaseGenerator.execute_query(db2.path, "select * from #{table};")

  return expected_rows == merge_rows(rows1, rows2)
end

def merge_rows(rows1, rows2)
  rows1.concat(rows2.each { |x| rows1.include? x  })
end