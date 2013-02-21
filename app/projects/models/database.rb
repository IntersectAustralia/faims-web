class Database
  require 'sqlite3'

  def self.load_arch_entity(file,type, limit, offset)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    if !type.eql?"all"
      uuid = db.execute("

        SELECT uuid, aenttypename, attributename, coalesce(vocabname, measure, freetext) AS responce, vocabid, attributeid, max(tstamp, astamp)
             FROM idealaent
             JOIN aenttype USING (aenttypeid)
             JOIN archentity USING (aenttypeid)
             JOIN aentvalue USING (UUID, attributeid)
             JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
             JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
             JOIN attributekey USING (attributeid)
             LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
            WHERE isIdentifier = 'true'
              AND uuid in (SELECT uuid
                             FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp
                                     FROM archentity
                                    WHERE aenttypeid = ?
                                 GROUP BY uuid, aenttypeid
                                   HAVING max(aenttimestamp)
                                      AND deleted IS null)
                             JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp
                                     FROM aentvalue
                                 GROUP BY uuid
                                   HAVING max(valuetimestamp)
                                   AND deleted IS null) USING (uuid)
                         ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                            LIMIT ?
                           OFFSET ?)
         GROUP BY uuid, attributeid
           HAVING max(valuetimestamp)
              AND max(aenttimestamp)
         ORDER BY max(tstamp,astamp) desc, uuid, attributename;",type,limit, offset)
    else
      uuid = db.execute("

          SELECT uuid, aenttypename, attributename, coalesce(vocabname, measure, freetext) AS responce, vocabid, attributeid, max(tstamp, astamp)
               FROM idealaent
               JOIN aenttype USING (aenttypeid)
               JOIN archentity USING (aenttypeid)
               JOIN aentvalue USING (UUID, attributeid)
               JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
               JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
               JOIN attributekey USING (attributeid)
               LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
              WHERE isIdentifier = 'true'
                AND uuid in (SELECT uuid
                               FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp
                                       FROM archentity
                                   GROUP BY uuid, aenttypeid
                                     HAVING max(aenttimestamp)
                                        AND deleted IS null)
                               JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp
                                       FROM aentvalue
                                   GROUP BY uuid
                                     HAVING max(valuetimestamp)
                                     AND deleted IS null) USING (uuid)
                           ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
                              LIMIT ?
                             OFFSET ?)
           GROUP BY uuid, attributeid
             HAVING max(valuetimestamp)
                AND max(aenttimestamp)
           ORDER BY max(tstamp,astamp) desc, uuid, attributename;",limit, offset)
    end
    uuid
  end

  def self.get_arch_entity_attributes(file, uuid)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    attributes = db.execute("
      SELECT uuid, attributeid, vocabid, attributename, vocabname, measure, freetext, certainty
              FROM (    SELECT uuid, attributeid, aenttypeid
                       FROM (SELECT aenttypeid, attributeid, aentdescription
                               FROM idealaent
                              )
                       JOIN (select uuid, aenttypeid
                               from archentity
                               where deleted is null and uuid = ?
                               GROUP BY uuid
                               having max(aenttimestamp)) USING (aenttypeid)
                       )
              JOIN aentvalue USING (uuid, attributeid)
              JOIN attributekey using (attributeid)
              left outer join vocabulary using (vocabid, attributeid)
        group by uuid, attributeid
        having max(valuetimestamp) order by uuid, attributename asc;",uuid)
    attributes
  end

  def self.update_arch_entity_attribute(file, uuid, vocab_id, attribute_id, measure, freetext, certainty)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, CURRENT_TIMESTAMP, 0, 1 from version;")
    db.execute("insert into AEntValue (uuid, VocabID, AttributeID, Measure, FreeText, Certainty, ValueTimestamp, versionnum) values (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP
              , (select versionnum from version where ismerged = 1 order by versionnum desc limit 1));",uuid, vocab_id, attribute_id, measure, freetext, certainty)
  end

  def self.delete_arch_entity(file, uuid)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, CURRENT_TIMESTAMP, 0, 1 from version;")
    db.execute("insert into archentity (uuid, userid, AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, AEntTimestamp, deleted, versionnum)
              select uuid, userid,AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, CURRENT_TIMESTAMP,'true',
              (select versionnum from version where ismerged = 1 order by versionnum desc limit 1) from archentity where uuid = ?",uuid)
  end

  def self.load_rel(file, type, limit, offset)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    if !type.eql?"all"
      rel_uuid = db.execute("
          SELECT relationshipid, RelnTypeName, attributename, coalesce(vocabname, freetext) as responce, vocabid, attributeid, max(tstamp, astamp)
              FROM idealreln
              JOIN relntype using (relntypeid)
              JOIN Relationship USING (relntypeid)
              JOIN relnvalue USING (relationshipid, attributeid)
              JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
              JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM Relationship GROUP BY relationshipid) USING (relationshipid)
              JOIN attributekey USING (attributeid)
              LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
             WHERE isIdentifier = 'true'
               AND relationshipid in (SELECT relationshipid
                                   FROM (SELECT relationshipid, relntypeid, max(relntimestamp) as relntimestamp
                                           FROM relationship
                                          WHERE relntypeid = ?
                                       GROUP BY relationshipid, relntypeid
                                         HAVING max(relntimestamp)
                                            AND deleted IS null)
                                   JOIN (SELECT relationshipid, max(relnvaluetimestamp) as valuetimestamp
                                           FROM relnvalue
                                       GROUP BY relationshipid
                                         HAVING max(relnvaluetimestamp)
                                         AND deleted IS null) USING (relationshipid)
                               ORDER BY max(valuetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                 OFFSET ?)
           GROUP BY relationshipid, attributeid
             HAVING max(relntimestamp)
                AND max(relnvaluetimestamp)
           ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;",type,limit, offset)
    else
      rel_uuid = db.execute("
          SELECT relationshipid, RelnTypeName, attributename, coalesce(vocabname, freetext) as responce, vocabid, attributeid, max(tstamp, astamp)
              FROM idealreln
              JOIN relntype using (relntypeid)
              JOIN Relationship USING (relntypeid)
              JOIN relnvalue USING (relationshipid, attributeid)
              JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
              JOIN (SELECT relationshipid, max(relntimestamp) AS astamp FROM Relationship GROUP BY relationshipid) USING (relationshipid)
              JOIN attributekey USING (attributeid)
              LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
             WHERE isIdentifier = 'true'
               AND relationshipid in (SELECT relationshipid
                                   FROM (SELECT relationshipid, relntypeid, max(relntimestamp) as relntimestamp
                                           FROM relationship
                                       GROUP BY relationshipid, relntypeid
                                         HAVING max(relntimestamp)
                                            AND deleted IS null)
                                   JOIN (SELECT relationshipid, max(relnvaluetimestamp) as valuetimestamp
                                           FROM relnvalue
                                       GROUP BY relationshipid
                                         HAVING max(relnvaluetimestamp)
                                         AND deleted IS null) USING (relationshipid)
                               ORDER BY max(valuetimestamp, relntimestamp) desc, relationshipid
                                  LIMIT ?
                                 OFFSET ?)
           GROUP BY relationshipid, attributeid
             HAVING max(relntimestamp)
                AND max(relnvaluetimestamp)
           ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;",limit, offset)
    end
    rel_uuid
  end

  def self.get_rel_attributes(file, relationshipid)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    attributes = db.execute("
      SELECT relationshipid, vocabid, attributeid, RelnTypeName, attributename, vocabname, freetext, certainty
          FROM (SELECT relationshipid, attributeid, RelnTypeName
                  FROM (SELECT relntypeid, attributeid, relntypename
                          FROM idealreln join relntype using (relntypeid))
                  JOIN (SELECT relationshipid, relntypeid
                          FROM relationship
                         WHERE deleted is null and relationshipid = ?
                          and relntypeid in (select relntypeid from idealreln)
                      GROUP BY relationshipid
                        HAVING max(relntimestamp)) USING (relntypeid)
                )
          JOIN relnvalue USING (relationshipid, attributeid)
          JOIN attributekey using (attributeid)
          LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
      GROUP BY relationshipid, attributeid
        HAVING max(relnvaluetimestamp) order by relationshipid, attributename asc;",relationshipid)
    attributes
  end

  def self.update_rel_attribute(file, relationshipid, vocab_id, attribute_id, freetext, certainty)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, CURRENT_TIMESTAMP, 0, 1 from version;")
    db.execute("insert into RelnValue (RelationshipID, AttributeID, VocabID, FreeText, Certainty, RelnValueTimestamp, versionnum) values (?, ?, ?, ?, ?, CURRENT_TIMESTAMP,
              (select versionnum from version where ismerged = 1 order by versionnum desc limit 1));",relationshipid, attribute_id, vocab_id, freetext, certainty)
  end

  def self.delete_relationship(file, relationshipid)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, CURRENT_TIMESTAMP, 0, 1 from version;")
    db.execute("insert into relationship (RelationshipID, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, RelnTimestamp, deleted, versionnum)
              select RelationshipID, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, CURRENT_TIMESTAMP,'true',
              (select versionnum from version where ismerged = 1 order by versionnum desc limit 1) from relationship where RelationshipID = ?;",relationshipid)
  end

  def self.get_vocab(file,attributeid)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    vocabs = db.execute("select vocabname, vocabid from vocabulary where attributeid = ?",attributeid)
    vocabs
  end

  def self.get_arch_ent_types(file)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    types = db.execute("select aenttypename, aenttypeid from aenttype")
    types
  end

  def self.get_rel_types(file)
    db = SQLite3::Database.new(file)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    types = db.execute("select relntypename, relntypeid from relntype")
    types
  end

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

  def self.current_version(db)
    db = SQLite3::Database.new(db)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("select versionnum from version where ismerged = 1 order by versionnum desc").first
  end

  def self.add_version(db, userid)
    db = SQLite3::Database.new(db)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    content = <<EOF
    insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, CURRENT_TIMESTAMP, #{userid}, 0 from version;
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
insert into archentity (uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, versionnum, geospatialcolumn, deleted) select uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, #{version}, geospatialcolumn, deleted from import.archentity where uuid || aenttimestamp not in (select uuid || aenttimestamp from archentity);
insert into aentvalue (uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, versionnum, deleted) select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, #{version}, deleted from import.aentvalue where uuid || valuetimestamp || attributeid not in (select uuid || valuetimestamp||attributeid from aentvalue);
insert into relationship (relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, versionnum, geospatialcolumn, deleted) select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, #{version}, geospatialcolumn, deleted from import.relationship where relationshipid || relntimestamp not in (select relationshipid || relntimestamp from relationship);
insert into relnvalue (relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, versionnum, deleted) select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, #{version},deleted from import.relnvalue where relationshipid || relnvaluetimestamp || attributeid not in (select relationshipid || relnvaluetimestamp || attributeid from relnvalue);
insert into aentreln (uuid, relationshipid, participatesverb, aentrelntimestamp, versionnum, deleted) select uuid, relationshipid, participatesverb, aentrelntimestamp, #{version}, deleted from import.aentreln where uuid || relationshipid || aentrelntimestamp not in (select uuid || relationshipid || aentrelntimestamp from aentreln);
detach database import;

update version set ismerged = 1 where versionnum = #{version};
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
attach database "?" as export;
create table export.user as select * from user;
create table export.aenttype as select * from aenttype;
create table export.attributekey as select * from attributekey;
create table export.vocabulary as select * from vocabulary;
create table export.relntype as select * from relntype;
create table export.idealaent as select * from idealaent;
create table export.idealreln as select * from idealreln;
create table export.archentity as select uuid, aenttimestamp, userid, doi, deleted, aenttypeid, geospatialcolumntype, geospatialcolumn from archentity;
create table export.aentvalue as select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, deleted from aentvalue;
create table export.relationship as select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, geospatialcolumn, deleted from relationship;
create table export.relnvalue as select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext,deleted from relnvalue;
create table export.aentreln as select uuid, relationshipid, participatesverb, deleted, aentrelntimestamp from aentreln;
detach database export;
EOF
    content = content.gsub("\n", "")
    content = content.gsub("?", toDB)
    db.execute_batch(content)
  end

  def self.create_app_database_from_version(fromDB, toDB, version)
    db = SQLite3::Database.new(toDB)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    db.execute("select initspatialmetadata()")

    db = SQLite3::Database.new(fromDB)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{spatialite_library}')")
    content = <<EOF
attach database "?" as export;
create table export.archentity as select uuid, aenttimestamp, userid, doi, deleted, aenttypeid, geospatialcolumntype, geospatialcolumn from archentity where versionnum >= #{version};
create table export.aentvalue as select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, deleted from aentvalue where versionnum >= #{version};
create table export.relationship as select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, geospatialcolumn, deleted from relationship where versionnum >= #{version};
create table export.relnvalue as select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext,deleted from relnvalue where versionnum >= #{version};
create table export.aentreln as select uuid, relationshipid, participatesverb, deleted, aentrelntimestamp from aentreln where versionnum >= #{version};
detach database export;
EOF
    content = content.gsub("\n", "")
    content = content.gsub("?", toDB)
    db.execute_batch(content)
  end
end