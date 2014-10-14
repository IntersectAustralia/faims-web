-- alter table User add column UserDeleted Boolean;
-- alter table AttributeKey add FormatString UserDeleted Text;
-- alter table Vocabulary add VocabCountOrder Integer;
-- alter table Vocabulary add VocabDeleted Boolean;
-- alter table IdealAEnt add AEntCountOrder Boolean;

-- CREATE TABLE File (
--   Filename             TEXT PRIMARY KEY,
--   MD5Checksum          TEXT    NOT NULL,
--   Size                 INTEGER NOT NULL,
--   Type                 TEXT, -- either Settings, Database, Data files, App files or Server only files
--   State                TEXT, -- either null (if not on device), downloaded (if downloaded from server), uploaded (if sent to server)
--   Timestamp            DATETIME DEFAULT CURRENT_TIMESTAMP,
--   Deleted              BOOLEAN,
--   ThumbnailFilename    TEXT,
--   ThumbnailSize        INTEGER,
--   ThumbnailMD5Checksum TEXT
-- );

-- CREATE TABLE AentValue2 (
--   UUID            INTEGER NOT NULL,
--   ValueTimestamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
--   UserID          INTEGER NOT NULL REFERENCES User,
--   AttributeID     TEXT    NOT NULL REFERENCES AttributeKey,
--   VocabID         INTEGER REFERENCES Vocabulary,
--   Measure         TEXT,
--   FreeText        TEXT,
--   Certainty       REAL,
--   Deleted         BOOLEAN,
--   VersionNum      INTEGER REFERENCES Version,
--   isDirty         BOOLEAN, --validation "dirty bit"
--   isDirtyReason   TEXT,
--   isForked        BOOLEAN, -- fork signalling
--   ParentTimestamp DATETIME -- nominally we'd reference Archent here, but just no. No.
--   , UNIQUE (UUID, ValueTimestamp, UserID, AttributeID, VocabID, Measure, FreeText, Certainty, Deleted)
--   ON CONFLICT REPLACE
-- );

-- INSERT INTO AentValue2 SELECT UUID, ValueTimestamp, UserID, AttributeID, VocabID, Measure, FreeText, Certainty, Deleted, VersionNum, isDirty, isDirtyReason, isForked, ParentTimestamp FROM AentValue;

-- DROP Table AentValue;

-- ALTER TABLE AentValue2 RENAME TO AentValue;
--
-- alter table AttributeKey add column AttributeIsFile Boolean;
-- alter table AttributeKey add column AttributeUseThumbnail Boolean;

alter table AttributeKey add column AppendCharacterString TEXT;
alter table AttributeKey add column SemanticMapURL TEXT;

update AttributeKey set AppendCharacterString = ',';

drop view if exists createdModifiedAtBy;
create view createdModifiedAtBy as select uuid, createdAt, createdBy, modifiedAt, modifiedBy, modifiedUserid, createdUserid
                                   from (select uuid, aenttimestamp as createdAt, fname || ' ' || lname as createdBy, userid as createdUserid
                                         from archentity join user using (userid)
                                         where uuid in (select uuid from latestnondeletedarchent)
                                         group by uuid
                                         having min(aenttimestamp)) as created
                                     join (select uuid, valuetimestamp as modifiedAt, fname || ' ' || lname as modifiedBy, userid as modifiedUserid
                                           from latestnondeletedaentvalue join user using (userid)
                                           group by uuid) using (uuid)		  ;

drop view if exists allCreatedModifiedAtBy;
create view allCreatedModifiedAtBy as select uuid, createdAt, createdBy, modifiedAt, modifiedBy, modifiedUserid, createdUserid
                                      from (select uuid, aenttimestamp as createdAt, fname || ' ' || lname as createdBy, userid as createdUserid
                                            from archentity join user using (userid)
                                            group by uuid
                                            having min(aenttimestamp)) as created
                                        join (select uuid, valuetimestamp as modifiedAt, fname || ' ' || lname as modifiedBy, userid as modifiedUserid
                                              from aentvalue join user using (userid)
                                              group by uuid
                                              having valuetimestamp = max(valuetimestamp)) using (uuid)     ;

drop view if exists latestNonDeletedArchEntFormattedIdentifiers;
create view if not exists latestNonDeletedArchEntFormattedIdentifiers as
  select uuid, aenttypeid, aenttypename, group_concat(format(formatstring, vocabname, measure, freetext, certainty), appendcharacterstring) as response, null as deleted
  from latestNonDeletedArchent
    JOIN aenttype using (aenttypeid)
    JOIN idealaent using (aenttypeid)
    join attributekey using (attributeid)
    join latestNonDeletedAentValue using (uuid, attributeid)
    left outer join vocabulary using (attributeid, vocabid)
  WHERE isIdentifier = 'true'
  group by uuid, attributeid
  having response is not null
  order by uuid, aentcountorder, vocabcountorder;

drop view if exists latestAllArchEntFormattedIdentifiers;
create view if not exists latestAllArchEntFormattedIdentifiers as
  select uuid, aenttypeid, aenttypename, group_concat(format(formatstring, vocabname, measure, freetext, certainty), appendcharacterstring) as response, archentity.deleted
  from archentity
    JOIN (select uuid, max(aenttimestamp) as aenttimestamp
          from archentity
          group by uuid) USING (uuid, aenttimestamp)
    join aentvalue using (uuid)
    JOIN (select uuid, attributeid, max(valuetimestamp) as ValueTimestamp
          from aentvalue
          group by uuid, attributeid) USING (uuid, attributeid, valuetimestamp)
    JOIN aenttype using (aenttypeid)
    JOIN idealaent using (aenttypeid, attributeid)
    join attributekey using (attributeid)
    left outer join vocabulary using (attributeid, vocabid)
  WHERE isIdentifier = 'true'
  group by uuid, attributeid
  having response is not null
  order by uuid, aentcountorder, vocabcountorder;
