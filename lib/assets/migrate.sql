--BEGIN;

ATTACH DATABASE 'FAIMS_1_3.sqlite3' AS db_from;
ATTACH DATABASE 'FAIMS_2_0.sqlite3' AS db_to;

/*
Migrate user table
Migrate version table
Migrate attributekey table
Migrate vocabulary table
Migrate archentity table
Migrate aentvalue table
Migrate relationship table
Migrate relnvalue table
Migrate aentreln table
*/

-- Migrate user table
REPLACE INTO db_to.User (UserID, FName, LName, Email)
  SELECT UserID, FName, LName, Email
  FROM db_from.User;

-- Migrate version table
REPLACE INTO db_to.Version (VersionNum, UploadTimestamp, UserID, IsMerged)
  SELECT VersionNum, UploadTimestamp, UserID, IsMerged
  FROM db_from.Version;

-- Migrate attributekey table (Assign attributeisfile if type = file)
update db_to.attributekey set attributeisfile = '1' where attributename in (select attributename from db_from.attributekey where attributetype = 'file');

-- Migrate vocabulary table (Add/Update vocabs)

SELECT
  main.vocabname,
  main.pictureurl,
  main.attributename,
  main.attributetype,
  parent.vocabname,
  parent.pictureurl,
  parent.attributename,
  parent.attributetype
FROM (db_from.vocabulary
  JOIN db_from.attributekey USING (attributeid)) main LEFT OUTER JOIN (SELECT
                                                                         vocabid,
                                                                         vocabname,
                                                                         pictureurl,
                                                                         attributename,
                                                                         attributetype
                                                                       FROM db_from.vocabulary
                                                                         JOIN db_from.attributekey
                                                                         USING (attributeid)) parent
    ON (db_from.vocabulary.parentvocabid = parent.vocabid)
EXCEPT
SELECT
  main.vocabname,
  main.pictureurl,
  main.attributename,
  main.attributetype,
  parent.vocabname,
  parent.pictureurl,
  parent.attributename,
  parent.attributetype
FROM (db_to.vocabulary
  JOIN db_to.attributekey USING (attributeid)) main LEFT OUTER JOIN (SELECT
                                                                       vocabid,
                                                                       vocabname,
                                                                       pictureurl,
                                                                       attributename,
                                                                       attributetype
                                                                     FROM db_to.vocabulary
                                                                       JOIN db_to.attributekey
                                                                       USING (attributeid)) parent
    ON (db_to.vocabulary.parentvocabid = parent.vocabid);

-- Migrate archentity table

REPLACE INTO db_to.archentity (UUID, AEntTimestamp, UserID, DOI, aenttypeid, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp, GeoSpatialColumnType, GeoSpatialColumn)
  SELECT UUID, AEntTimestamp, UserID, DOI, newID, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp, GeoSpatialColumnType, GeoSpatialColumn
  FROM
    db_from.archentity
  JOIN
    (SELECT
       aenttype_to.AEntTypeID newID,
       aenttype_from.AEntTypeID oldID
    FROM db_to.aenttype aenttype_to JOIN db_from.aenttype aenttype_from
    USING (aenttypename))
  ON (db_from.archentity.aenttypeid=oldID);

-- Migrate relationship table

REPLACE INTO db_to.relationship (RelationshipID, RelnTimestamp, UserID, relntypeid, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp, GeoSpatialColumnType, GeoSpatialColumn)
  SELECT RelationshipID, RelnTimestamp, UserID, newID, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp, GeoSpatialColumnType, GeoSpatialColumn
  FROM db_from.relationship
    JOIN (SELECT
            relntype_to.relntypeid newID,
            relntype_from.relntypeid oldID
          FROM db_to.relntype relntype_to JOIN db_from.relntype relntype_from
          USING (relntypename))
    ON (db_from.relationship.relntypeid=oldID);

REPLACE INTO db_to.aentvalue (UUID, ValueTimestamp, UserID, attributeid, vocabid, Measure, FreeText, Certainty, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp)
  SELECT UUID, ValueTimestamp, UserID, newAttribId, newVocabID, Measure, FreeText, Certainty, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp
    FROM
    (
      db_from.aentvalue
        JOIN
        db_from.attributekey
        USING (attributeid)
        LEFT OUTER JOIN
        db_from.vocabulary
        USING (vocabid, attributeid))
    JOIN
      (SELECT
        attributeid AS newAttribId, attributename
      FROM db_to.attributekey)
      USING (attributename)
    LEFT OUTER JOIN
      (SELECT
        attributeid AS newAttribID,
        vocabname,
        vocabid     AS newVocabID
      FROM
        db_to.vocabulary
        JOIN
        db_to.attributekey
        USING (attributeid))
      USING (vocabname, newAttribID);

-- Migrate relnvalue table

REPLACE INTO db_to.relnvalue (RelationshipID, RelnValueTimestamp, UserID, AttributeID, VocabID, Freetext, Certainty, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp)
  SELECT RelationshipID, RelnValueTimestamp, UserID, newAttribID, newVocabID, Freetext, Certainty, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp
  FROM
  (
    db_from.relnvalue
      JOIN
      db_from.attributekey
      USING (attributeid)
      LEFT OUTER JOIN
      db_from.vocabulary
      USING (vocabid, attributeid))
  JOIN
    (SELECT
      attributeid AS newAttribId, attributename
    FROM db_to.attributekey)
    USING (attributename)
  LEFT OUTER JOIN
    (SELECT
      attributeid AS newAttribID,
      vocabname,
      vocabid     AS newVocabID
    FROM
      db_to.vocabulary
      JOIN
      db_to.attributekey
      USING (attributeid))
    USING (vocabname, newAttribID);

-- Migrate antreln table
REPLACE INTO db_to.aentreln (UUID, RelationshipID, UserID, AEntRelnTimestamp, ParticipatesVerb, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp)
  SELECT UUID, RelationshipID, UserID, AEntRelnTimestamp, ParticipatesVerb, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp
  FROM db_from.aentreln;

-- Update freetext values to measure values
update db_to.aentvalue set measure = freetext where measure is null and freetext is not null and vocabid is null;
update db_to.aentvalue set freetext = null where measure = freetext;