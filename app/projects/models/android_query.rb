module AndroidQuery

  # ANROID

  def self.insert_arch_entity
    query = <<EOF
INSERT INTO ArchEntity (uuid, userid, AEntTypeID, GeoSpatialColumn, AEntTimestamp)
SELECT cast(? as integer), ?, aenttypeid, GeomFromText(?, 4326), ?
FROM aenttype
WHERE aenttypename = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.insert_arch_entity_attribute
    query = <<EOF
INSERT INTO AEntValue (uuid, VocabID, AttributeID, Measure, FreeText, Certainty, ValueTimestamp)
SELECT cast(? as integer), ?, attributeID, ?, ?, ?, ?
FROM AttributeKey
WHERE attributeName = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.insert_relationship
    query = <<EOF
INSERT INTO Relationship (RelationshipID, userid, RelnTypeID, GeoSpatialColumn, RelnTimestamp)
SELECT cast(? as integer), ?, relntypeid, GeomFromText(?, 4326), ?
FROM relntype
WHERE relntypename = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.insert_relationship_attribute
    query = <<EOF
INSERT INTO RelnValue (RelationshipID, VocabID, AttributeID, FreeText, Certainty, RelnValueTimestamp)
SELECT cast(? as integer), ?, attributeId, ?, ?, ?
FROM AttributeKey
WHERE attributeName = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.has_arch_entity_attribute
    query = <<EOF
SELECT count(AEntTypeName)
FROM IdealAEnt left outer join AEntType using (AEntTypeId) left outer join AttributeKey using (AttributeId)
WHERE AEntTypeName = ? COLLATE NOCASE and AttributeName = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.has_relationship_attribute
    query = <<EOF
SELECT count(RelnTypeName)
FROM IdealReln left outer join RelnType using (RelnTypeID) left outer join AttributeKey using (AttributeId)
WHERE RelnTypeName = ? COLLATE NOCASE and AttributeName = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.insert_arch_entity_relationship
    query = <<EOF
INSERT INTO AEntReln (UUID, RelationshipID, ParticipatesVerb, AEntRelnTimestamp)
VALUES (?, ?, ?, ?);
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.fetch_arch_entity
    query = <<EOF
SELECT uuid, attributename, vocabid, measure, freetext, certainty, AEntTypeID, aenttimestamp, valuetimestamp FROM
  (SELECT uuid, attributeid, vocabid, measure, freetext, certainty, valuetimestamp FROM aentvalue WHERE uuid || valuetimestamp || attributeid in
    (SELECT uuid || max(valuetimestamp) || attributeid FROM aentvalue WHERE uuid = ? GROUP BY uuid, attributeid having deleted is null) )
JOIN attributekey USING (attributeid)
JOIN ArchEntity USING (uuid)
where uuid || aenttimestamp in ( select uuid || max(aenttimestamp) from archentity group by uuid having deleted is null);
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.fetch_arch_entity_geometry
    query = <<EOF
SELECT uuid, HEX(AsBinary(GeoSpatialColumn)) from ArchEntity where uuid || aenttimestamp IN ( SELECT uuid || max(aenttimestamp) FROM archentity WHERE uuid = ?);
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.fetch_relationship
    query = <<EOF
SELECT relationshipid, attributename, vocabid, freetext, certainty, relntypeid FROM
  (SELECT relationshipid, attributeid, vocabid, freetext, certainty FROM relnvalue WHERE relationshipid || relnvaluetimestamp || attributeid in
    (SELECT relationshipid || max(relnvaluetimestamp) || attributeid FROM relnvalue WHERE relationshipid = ? GROUP BY relationshipid, attributeid having deleted is null))
JOIN attributekey USING (attributeid)
JOIN Relationship USING (relationshipid)
where relationshipid || relntimestamp in (select relationshipid || max (relntimestamp) from relationship group by relationshipid having deleted is null )
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.fetch_relationship_geometry
    query = <<EOF
SELECT relationshipid, HEX(AsBinary(GeoSpatialColumn)) from relationship where relationshipid || relntimestamp IN ( SELECT relationshipid || max(relntimestamp) FROM relationship WHERE relationshipid = ?);
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.has_arch_entity_type
    query = <<EOF
select count(AEntTypeID) from AEntType where AEntTypeName = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.has_arch_entity
    query = <<EOF
select count(UUID) from ArchEntity where UUID = ?;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.has_relationship_type
    query = <<EOF
select count(RelnTypeID) from RelnType where RelnTypeName = ? COLLATE NOCASE;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

  def self.has_relationship
    query = <<EOF
select count(RelationshipID) from Relationship where RelationshipID = ?;
EOF
    query.gsub("\n", " ").gsub("\t", "")
  end

end