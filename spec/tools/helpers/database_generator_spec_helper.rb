require Rails.root.join('features/support/project_modules')

def init_database(db)
  
end

def fill_database(db, version = nil, seed = nil)
  init_database(db)

  version ||= 1 # default version

  s = 0
  n = s + 5

  index = seed ? seed : 0

  (s..n).each do |i|
    db.execute("INSERT INTO archentity (uuid, userid, aenttypeid, aenttimestamp, versionnum) " +
        "VALUES (cast('#{index}' as integer), '0', 'ExcavationUnitStructure', CURRENT_TIMESTAMP, #{version});")

    (s..n).each do |j|
      db.execute("INSERT INTO aentvalue (uuid, userid, vocabid, attributeid, measure, freetext, certainty, valuetimestamp, versionnum) " +
          "SELECT cast('#{index}' as integer), '0', '0', attributeid, '0', 'Text', '0', CURRENT_TIMESTAMP, #{version} " +
          "FROM attributekey " +
          "WHERE attributeName = 'Excavator' COLLATE NOCASE;")
      index = index + 1
    end
  end

  index = seed ? seed : 0

  (s..n).each do |i|
    db.execute("INSERT INTO relationship (relationshipid, userid, relnTypeid, relntimestamp, versionnum) " +
        "VALUES (cast('#{index}' as integer), '0', 'Area', CURRENT_TIMESTAMP, #{version});")

    (s..n).each do |j|
      db.execute("INSERT INTO relnvalue (relationshipid, userid, vocabid, attributeid, freetext, certainty, relnvaluetimestamp, versionnum) " +
          "SELECT cast('#{index}' as integer), '0', '0', attributeid, 'Text', '1.0', CURRENT_TIMESTAMP, #{version} " +
          "FROM attributekey " +
          "WHERE attributeName = 'Excavator' COLLATE NOCASE;")
      index = index + 1
    end
  end

  index = seed ? seed : 0

  (s..n).each do |i|
    db.execute("INSERT INTO aentreln (uuid, relationshipid, userid, participatesverb, aentrelntimestamp, versionnum) " +
                                        "VALUES ('#{index}', '#{index}', '0', '', CURRENT_TIMESTAMP, #{version});")
    index = index + 1
  end
  
  db
end

def backup_database(db)
  file = Tempfile.new('copy')
  FileUtils.copy_file(db.path, file.path)
  
  SpatialiteDB.new(file.path)
end

def is_database_empty(db)
  return false if db.execute("select * from archentity;") != []
  return false if db.execute("select * from aentvalue;") != []
  return false if db.execute("select * from relationship;") != []
  return false if db.execute("select * from relnvalue;") != []
  return false if db.execute("select * from aentreln;") != []
  return true
end

def is_database_same(db1, db2)
  return false if db1.execute("select * from archentity;") !=
      db2.execute("select * from archentity;")
  return false if db1.execute("select * from aentvalue;") !=
      db2.execute("select * from aentvalue;")
  return false if db1.execute("select * from relationship;") !=
      db2.execute("select * from relationship;")
  return false if db1.execute("select * from relnvalue;") !=
      db2.execute("select * from relnvalue;")
  return false if db1.execute("select * from aentreln;") !=
      db2.execute("select * from aentreln;")
  return true
end

def is_version_database_same(db1, db2, version)
  return false if db1.execute("select uuid, aenttimestamp, userid, doi, aenttypeid, deleted, isdirty, isdirtyreason, isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn from archentity where versionnum = #{version};") !=
      db2.execute("select uuid, aenttimestamp, userid, doi, aenttypeid, deleted, isdirty, isdirtyreason, isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn from archentity;")
  return false if db1.execute("select uuid, valuetimestamp, userid, attributeid, vocabid, freetext, measure, certainty, deleted, isdirty, isdirtyreason, isforked, parenttimestamp from aentvalue where versionnum = #{version};") !=
      db2.execute("select uuid, valuetimestamp, userid, attributeid, vocabid, freetext, measure, certainty, deleted, isdirty, isdirtyreason, isforked, parenttimestamp from aentvalue;")
  return false if db1.execute("select relationshipid, userid, relntimestamp, relntypeid, deleted, isdirty, isdirtyreason, isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn from relationship where versionnum = #{version};") !=
    db2.execute("select relationshipid, userid, relntimestamp, relntypeid, deleted, isdirty, isdirtyreason, isforked, parenttimestamp, geospatialcolumntype, geospatialcolumn from relationship;")
  return false if db1.execute("select relationshipid, relnvaluetimestamp, userid, attributeid, vocabid, freetext, certainty, deleted, isdirty, isdirtyreason, isforked, parenttimestamp from relnvalue where versionnum = #{version};") !=
    db2.execute("select relationshipid, relnvaluetimestamp, userid, attributeid, vocabid, freetext, certainty, deleted, isdirty, isdirtyreason, isforked, parenttimestamp from relnvalue;")
  return false if db1.execute("select uuid, relationshipid, userid, aentrelntimestamp, participatesverb, deleted, isdirty, isdirtyreason, isforked, parenttimestamp from aentreln where versionnum = #{version};") !=
    db2.execute("select uuid, relationshipid, userid, aentrelntimestamp, participatesverb, deleted, isdirty, isdirtyreason, isforked, parenttimestamp from aentreln;")
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
  expected_rows = db.execute("select * from #{table};")

  rows1 = db1.execute("select * from #{table};")
  rows2 = db2.execute("select * from #{table};")

  return expected_rows == merge_rows(rows1, rows2)
end

def merge_rows(rows1, rows2)
  rows1.concat(rows2.select { |x| !rows1.include? x  })
end