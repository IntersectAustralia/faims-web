module WebQuery

  # WEB

  def self.load_arch_entities
    cleanup_query(<<EOF
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
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.load_all_arch_entities
    cleanup_query(<<EOF
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
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.search_arch_entity
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(vocabname, measure, freetext) AS response, vocabid, attributeid, max(tstamp, astamp)
FROM aenttype
JOIN archentity USING (aenttypeid)
JOIN aentvalue USING (UUID)
JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
JOIN attributekey USING (attributeid)
LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE uuid in (SELECT uuid
               FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp
                       FROM archentity
                   GROUP BY uuid, aenttypeid
                     HAVING max(aenttimestamp)
                        AND deleted IS null)
               JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp
                       FROM aentvalue LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
                   GROUP BY uuid, attributeid
                     HAVING max(valuetimestamp)
                     AND deleted IS null
                     AND ( vocabname LIKE '%'||?||'%'
                         OR freetext LIKE '%'||?||'%'
                         OR measure LIKE '%'||?||'%')) USING (uuid)
           ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
              LIMIT ?
             OFFSET ?)
GROUP BY uuid, attributeid
HAVING max(valuetimestamp)
AND max(aenttimestamp)
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.get_arch_entity_attributes
    cleanup_query(<<EOF
SELECT uuid, attributeid, vocabid, attributename, vocabname, measure, freetext, certainty
from aentvalue join attributekey using(attributeid)
  LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
where uuid = ? and deleted is null
GROUP BY uuid, attributeid
HAVING max(ValueTimestamp) order by uuid, attributename asc;
EOF
    )
  end

  def self.insert_version
    cleanup_query(<<EOF
insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, ?, 0, 1 from version;
EOF
    )
  end

  def self.insert_arch_entity_attribute
    cleanup_query(<<EOF
insert into AEntValue (uuid, VocabID, AttributeID, Measure, FreeText, Certainty, ValueTimestamp, versionnum) values (?, ?, ?, ?, ?, ?, ?,
  (select versionnum from version where ismerged = 1 order by versionnum desc limit 1));
EOF
    )
  end

  def self.delete_arch_entity
    cleanup_query(<<EOF
insert into archentity (uuid, userid, AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, AEntTimestamp, deleted, versionnum)
select uuid, userid,AEntTypeID, GeoSpatialColumnType, GeoSpatialColumn, ?,'true',
  (select versionnum from version where ismerged = 1 order by versionnum desc limit 1)
from archentity where uuid = ?
EOF
    )
  end

  def self.load_relationships
    cleanup_query(<<EOF
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
                             WHERE relntypeid in (select relntypeid from idealreln where isIdentifier = 'true' group by relntypeid)
                             and relntypeid = ?
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
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.load_all_relationships
    cleanup_query(<<EOF
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
                             WHERE relntypeid in (select relntypeid from idealreln where isIdentifier = 'true' group by relntypeid)
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
ORDER BY max(tstamp,astamp) desc, relationshipid, attributename;
EOF
    )
  end

  def self.search_relationship
    cleanup_query(<<EOF
SELECT relationshipid, attributename, coalesce(vocabname, freetext) as response, vocabname
FROM relnvalue
JOIN attributekey using (attributeid)
JOIN (SELECT relationshipid, max(relnvaluetimestamp) AS tstamp FROM relnvalue GROUP BY relationshipid) USING (relationshipid)
        LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
        WHERE relationshipid in (select relationshipid
                                    FROM relnvalue left outer join vocabulary using (vocabid, attributeid) join (select relationshipid from relationship group by relationshipid having max(relntimestamp) and deleted is null) using (relationshipid)
                                GROUP BY relationshipid, attributeid
                                  having max(relnvaluetimestamp)
                                     AND deleted is null
                                     AND (freetext like '%'||?||'%'
                                      OR vocabname like '%'||?||'%')
                                ORDER BY max(relnvaluetimestamp) desc, relationshipid
                                  limit ?
                                 offset ?
      )
GROUP BY relationshipid, attributeid
HAVING max(relnvaluetimestamp)
order by tstamp desc, relationshipid, attributename ;
EOF
    )
  end

  def self.get_relationship_attributes
    cleanup_query(<<EOF
SELECT relationshipid, vocabid, attributeid, attributename, freetext, certainty, vocabname, relntypeid
from relnvalue r join attributekey using(attributeid) join relationship using(relationshipid)
LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
where r.relationshipid = ? and r.deleted is null
GROUP BY relationshipid, attributeid
HAVING max(relnvaluetimestamp) order by relationshipid, attributename asc;
EOF
    )
  end

  def self.insert_relationship_attribute
    cleanup_query(<<EOF
insert into RelnValue (RelationshipID, AttributeID, VocabID, FreeText, Certainty, RelnValueTimestamp, versionnum) values (?, ?, ?, ?, ?, ?,
  (select versionnum from version where ismerged = 1 order by versionnum desc limit 1));
EOF
    )
  end

  def self.delete_relationship
    cleanup_query(<<EOF
insert into relationship (RelationshipID, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, RelnTimestamp, deleted, versionnum)
select RelationshipID, userid, RelnTypeID, GeoSpatialColumnType, GeoSpatialColumn, ?,'true',
  (select versionnum from version where ismerged = 1 order by versionnum desc limit 1)
from relationship where RelationshipID = ?;
EOF
    )
  end

  def self.get_arch_entities_in_relationship
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(vocabname, measure, freetext) AS response, vocabid, attributeid, max(tstamp, astamp)
FROM aenttype
JOIN archentity USING (aenttypeid)
JOIN aentvalue USING (UUID)
JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
JOIN attributekey USING (attributeid)
LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE uuid in (SELECT uuid
               FROM aentreln
               where relationshipid = ?
               group by uuid, relationshipid
               having deleted is null
              LIMIT ?
             OFFSET ?)
GROUP BY uuid, attributeid
HAVING max(valuetimestamp)
  AND max(aenttimestamp)
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.get_arch_entities_not_in_relationship
    cleanup_query(<<EOF
SELECT uuid, aenttypename, attributename, coalesce(vocabname, measure, freetext) AS response, vocabid, attributeid, max(tstamp, astamp)
FROM aenttype
JOIN archentity USING (aenttypeid)
JOIN aentvalue USING (UUID)
JOIN (SELECT uuid, max(valuetimestamp) AS tstamp FROM aentvalue GROUP BY uuid) USING (uuid)
JOIN (SELECT uuid, max(aenttimestamp) AS astamp FROM archentity GROUP BY uuid) USING (uuid)
JOIN attributekey USING (attributeid)
LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
WHERE uuid in (SELECT uuid
               FROM (SELECT uuid, aenttypeid, max(aenttimestamp) as aenttimestamp
                       FROM archentity
                   GROUP BY uuid, aenttypeid
                     HAVING max(aenttimestamp)
                        AND deleted IS null)
               JOIN (SELECT uuid, max(valuetimestamp) as valuetimestamp
                       FROM aentvalue LEFT OUTER JOIN vocabulary USING (vocabid, attributeid)
                   GROUP BY uuid, attributeid
                     HAVING max(valuetimestamp)
                     AND deleted IS null
                     AND ( vocabname LIKE '%'||?||'%'
                         OR freetext LIKE '%'||?||'%'
                         OR measure LIKE '%'||?||'%')) USING (uuid)
               WHERE uuid not in (
                     SELECT uuid
                       FROM aentreln
                      WHERE Relationshipid = ?
                     GROUP BY uuid, relationshipid
                      having max(aentrelntimestamp)
                          and deleted is null
                )
           ORDER BY max(valuetimestamp, aenttimestamp) desc, uuid
              LIMIT ?
             OFFSET ?)
GROUP BY uuid, attributeid
HAVING max(valuetimestamp)
  AND max(aenttimestamp)
ORDER BY max(tstamp,astamp) desc, uuid, attributename;
EOF
    )
  end

  def self.get_verbs_for_relationship
    cleanup_query(<<EOF
select parent from relntype where relntypeid = ? union select child from relntype where relntypeid = ?;
EOF
    )
  end

  def self.insert_arch_entity_relationship
    cleanup_query(<<EOF
insert into aentreln (UUID, RelationshipID, ParticipatesVerb) values(?, ?, ?);
EOF
    )
  end

  def self.delete_arch_entity_relationship
    cleanup_query(<<EOF
insert into aentreln (UUID, RelationshipID, Deleted) values(?, ?, 'true');
EOF
    )
  end

  def self.get_vocab
    cleanup_query(<<EOF
select vocabname, vocabid from vocabulary where attributeid = ?
EOF
    )
  end

  def self.get_arch_entity_types
    cleanup_query(<<EOF
select aenttypename, aenttypeid from aenttype
EOF
    )
  end

  def self.get_relationship_types
    cleanup_query(<<EOF
select relntypename, relntypeid from relntype
EOF
    )
  end

  def self.get_current_version
    cleanup_query(<<EOF
select versionnum from version where ismerged = 1 order by versionnum desc
EOF
    )
  end

  def self.get_latest_version
    cleanup_query(<<EOF
select versionnum from version order by versionnum desc
EOF
    )
  end

  def self.insert_user_version
    cleanup_query(<<EOF
insert into version (versionnum, uploadtimestamp, userid, ismerged) select count(*) + 1, ?, ?, 0 from version;
EOF
    )
  end

  def self.merge_database(fromDB, version)
    cleanup_query(<<EOF
attach database "#{fromDB}" as import;
insert into archentity (uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, versionnum, geospatialcolumn, deleted) select uuid, aenttimestamp, userid, doi, aenttypeid, geospatialcolumntype, '#{version}', geospatialcolumn, deleted from import.archentity where uuid || aenttimestamp not in (select uuid || aenttimestamp from archentity);
insert into aentvalue (uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, versionnum, deleted) select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, '#{version}', deleted from import.aentvalue where uuid || valuetimestamp || attributeid not in (select uuid || valuetimestamp||attributeid from aentvalue);
insert into relationship (relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, versionnum, geospatialcolumn, deleted) select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, '#{version}', geospatialcolumn, deleted from import.relationship where relationshipid || relntimestamp not in (select relationshipid || relntimestamp from relationship);
insert into relnvalue (relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, versionnum, certainty, deleted) select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, '#{version}', certainty, deleted from import.relnvalue where relationshipid || relnvaluetimestamp || attributeid not in (select relationshipid || relnvaluetimestamp || attributeid from relnvalue);
insert into aentreln (uuid, relationshipid, participatesverb, aentrelntimestamp, versionnum, deleted) select uuid, relationshipid, participatesverb, aentrelntimestamp, '#{version}', deleted from import.aentreln where uuid || relationshipid || aentrelntimestamp not in (select uuid || relationshipid || aentrelntimestamp from aentreln);
detach database import;

update version set ismerged = 1 where versionnum = '#{version}';
EOF
    )
  end

  def self.create_app_database(toDB)
    cleanup_query(<<EOF
attach database "#{toDB}" as export;
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
create table export.relnvalue as select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, certainty, deleted from relnvalue;
create table export.aentreln as select uuid, relationshipid, participatesverb, deleted, aentrelntimestamp from aentreln;
detach database export;
EOF
    )
  end

  def self.create_app_database_from_version(toDB, version)
    cleanup_query(<<EOF
attach database "#{toDB}" as export;
create table export.archentity as select uuid, aenttimestamp, userid, doi, deleted, aenttypeid, geospatialcolumntype, geospatialcolumn from archentity where versionnum >= '#{version}';
create table export.aentvalue as select uuid, valuetimestamp, vocabid, attributeid, freetext, measure, certainty, deleted from aentvalue where versionnum >= #{version};
create table export.relationship as select relationshipid, userid, relntimestamp, geospatialcolumntype, relntypeid, geospatialcolumn, deleted from relationship where versionnum >= '#{version}';
create table export.relnvalue as select relationshipid, attributeid, vocabid, relnvaluetimestamp, freetext, certainty, deleted from relnvalue where versionnum >= '#{version}';
create table export.aentreln as select uuid, relationshipid, participatesverb, deleted, aentrelntimestamp from aentreln where versionnum >= '#{version}';
detach database export;
EOF
    )
  end

  private

  def self.cleanup_query(query)
    query.gsub("\n", " ").gsub("\t", "")
  end

end