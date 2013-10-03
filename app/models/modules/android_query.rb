module AndroidQuery

  # ANROID

  def self.insert_arch_entity
    cleanup_query(<<EOF
INSERT INTO ArchEntity (uuid, userid, AEntTypeID, GeoSpatialColumn, AEntTimestamp)
SELECT cast(? as integer), ?, aenttypeid, GeomFromText(?, 4326), ?
FROM aenttype
WHERE aenttypename = ? COLLATE NOCASE;
EOF
    )
  end

  def self.insert_arch_entity_attribute
    cleanup_query(<<EOF
INSERT INTO AEntValue (uuid, VocabID, AttributeID, Measure, FreeText, Certainty, ValueTimestamp)
SELECT cast(? as integer), ?, attributeID, ?, ?, ?, ?
FROM AttributeKey
WHERE attributeName = ? COLLATE NOCASE;
EOF
    )
  end

  def self.insert_relationship
    cleanup_query(<<EOF
INSERT INTO Relationship (RelationshipID, userid, RelnTypeID, GeoSpatialColumn, RelnTimestamp)
SELECT cast(? as integer), ?, relntypeid, GeomFromText(?, 4326), ?
FROM relntype
WHERE relntypename = ? COLLATE NOCASE;
EOF
    )
  end

  def self.insert_relationship_attribute
    cleanup_query(<<EOF
INSERT INTO RelnValue (RelationshipID, VocabID, AttributeID, FreeText, Certainty, RelnValueTimestamp)
SELECT cast(? as integer), ?, attributeId, ?, ?, ?
FROM AttributeKey
WHERE attributeName = ? COLLATE NOCASE;
EOF
    )
  end

  def self.has_arch_entity_attribute
    cleanup_query(<<EOF
SELECT count(AEntTypeName)
FROM IdealAEnt left outer join AEntType using (AEntTypeId) left outer join AttributeKey using (AttributeId)
WHERE AEntTypeName = ? COLLATE NOCASE and AttributeName = ? COLLATE NOCASE;
EOF
    )
  end

  def self.has_relationship_attribute
    cleanup_query(<<EOF
SELECT count(RelnTypeName)
FROM IdealReln left outer join RelnType using (RelnTypeID) left outer join AttributeKey using (AttributeId)
WHERE RelnTypeName = ? COLLATE NOCASE and AttributeName = ? COLLATE NOCASE;
EOF
    )
  end

  def self.insert_arch_entity_relationship
    cleanup_query(<<EOF
INSERT INTO AEntReln (UUID, RelationshipID, ParticipatesVerb, AEntRelnTimestamp)
VALUES (?, ?, ?, ?);
EOF
    )
  end

  def self.fetch_arch_entity
    cleanup_query(<<EOF
SELECT uuid, attributename, vocabid, measure, freetext, certainty, AEntTypeID, aenttimestamp, valuetimestamp FROM
  (SELECT uuid, attributeid, vocabid, measure, freetext, certainty, valuetimestamp FROM aentvalue WHERE uuid || valuetimestamp || attributeid in
    (SELECT uuid || max(valuetimestamp) || attributeid FROM aentvalue WHERE uuid = ? GROUP BY uuid, attributeid having deleted is null) )
JOIN attributekey USING (attributeid)
JOIN ArchEntity USING (uuid)
where uuid || aenttimestamp in ( select uuid || max(aenttimestamp) from archentity group by uuid having deleted is null);
EOF
    )
  end

  def self.fetch_arch_entity_geometry
    cleanup_query(<<EOF
SELECT uuid, HEX(AsBinary(GeoSpatialColumn)) from ArchEntity where uuid || aenttimestamp IN ( SELECT uuid || max(aenttimestamp) FROM archentity WHERE uuid = ?);
EOF
    )
  end

  def self.fetch_relationship
    cleanup_query(<<EOF
SELECT relationshipid, attributename, vocabid, freetext, certainty, relntypeid FROM
  (SELECT relationshipid, attributeid, vocabid, freetext, certainty FROM relnvalue WHERE relationshipid || relnvaluetimestamp || attributeid in
    (SELECT relationshipid || max(relnvaluetimestamp) || attributeid FROM relnvalue WHERE relationshipid = ? GROUP BY relationshipid, attributeid having deleted is null))
JOIN attributekey USING (attributeid)
JOIN Relationship USING (relationshipid)
where relationshipid || relntimestamp in (select relationshipid || max (relntimestamp) from relationship group by relationshipid having deleted is null )
EOF
    )
  end

  def self.fetch_relationship_geometry
    cleanup_query(<<EOF
SELECT relationshipid, HEX(AsBinary(GeoSpatialColumn)) from relationship where relationshipid || relntimestamp IN ( SELECT relationshipid || max(relntimestamp) FROM relationship WHERE relationshipid = ?);
EOF
    )
  end

  def self.has_arch_entity_type
    cleanup_query(<<EOF
select count(AEntTypeID) from AEntType where AEntTypeName = ? COLLATE NOCASE;
EOF
    )
  end

  def self.has_arch_entity
    cleanup_query(<<EOF
select count(UUID) from ArchEntity where UUID = ?;
EOF
    )
  end

  def self.has_relationship_type
    cleanup_query(<<EOF
select count(RelnTypeID) from RelnType where RelnTypeName = ? COLLATE NOCASE;
EOF
    )
  end

  def self.has_relationship
    cleanup_query(<<EOF
select count(RelationshipID) from Relationship where RelationshipID = ?;
EOF
    )
  end

  private

  def self.cleanup_query(query)
    query.gsub("\n", " ").gsub("\t", "")
  end

end