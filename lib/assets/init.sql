PRAGMA page_size = 4096;
PRAGMA cache_size = 400000;
PRAGMA temp_store = 2;

VACUUM;

-- The file table serves to store file information
CREATE TABLE File (
  Filename             TEXT PRIMARY KEY,
  MD5Checksum          TEXT    NOT NULL,
  Size                 INTEGER NOT NULL,
  Type                 TEXT, -- either Settings, Database, Data files, App files or Server only files
  State                TEXT, -- either null (if not on device), downloaded (if downloaded from server), uploaded (if sent to server)
  Timestamp            DATETIME DEFAULT CURRENT_TIMESTAMP,
  Deleted              BOOLEAN,
  ThumbnailFilename    TEXT,
  ThumbnailSize        INTEGER,
  ThumbnailMD5Checksum TEXT
);

-- The user table is incomplete. It however, holds user information.
CREATE TABLE User (
  UserID      INTEGER PRIMARY KEY,
  FName       TEXT NOT NULL,
  LName       TEXT NOT NULL,
  Email       TEXT NOT NULL,
  UserDeleted BOOLEAN
);


-- the version table control upload synchronization
CREATE TABLE Version (
  VersionNum      INTEGER PRIMARY KEY,
  UploadTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  UserID          INTEGER REFERENCES User,
  IsMerged        INTEGER
);


/* the start of the core archentity definition.
 * ArchEnts are intended to be containers of "fact", the AentType
 * defines a platonic ideal instance of a specific /type/ of archentity,
 * in combination of idealAent. (which serves to identify the "ideal" columns of
 * the nominal entity. AentType and IdealAent serve the equivalent role of a create
 * table statement in DML land.
 */
CREATE TABLE AEntType (
  AEntTypeID          INTEGER PRIMARY KEY,
  AEntTypeName        TEXT NOT NULL, -- table name
  AEntTypeCategory    TEXT, -- I'm honestly not sure what we use this for.
  AEntTypeDescription TEXT -- human description
);


/* the attributekey table serves to identify the possible columns across the
 * database. It is a central repository of columns by virtue of DKNF. Column
 * level metadata also goes here.
 */

CREATE TABLE AttributeKey (
  AttributeID           INTEGER PRIMARY KEY,
  AttributeType         TEXT, -- this is typing for external tools. It has no bearing internally
  AttributeName         TEXT NOT NULL, -- effectively column name
  AttributeDescription  TEXT, -- human-entered description for the "column"
  AttributeIsFile       BOOLEAN, -- this flags the attribute as a file type
  AttributeUseThumbnail BOOLEAN, -- this flags the attribute to generate thumbnails
  FormatString          TEXT
);

-- TODO tweak indexes for performance
-- create index atkey on attributekey(attributeid);
CREATE INDEX atkeyname ON attributekey (attributename, attributeid);

/* The vocabulary table is the "lookup" table for the database.
 * Cruically, vocabNames can be mapped to our Arch16n infrastructure. {this} represents a standard string replacement expression. It will
 * look in the arch16n file and replace {this} with whatever the mapping is.
 * Picture URL is a *relative* path to define a picture dictionary.
 * Semantic Map URL is the start of our attempt to represent semantic names (like cidoc-crm). It however, has not recieved any dev time.
 */

CREATE TABLE Vocabulary (
  VocabID          INTEGER PRIMARY KEY,
  AttributeID      INTEGER NOT NULL REFERENCES AttributeKey,
  VocabName        TEXT    NOT NULL, -- This is the human-visible part of vocab that forms lookup tables. It is likely to be Arch16nized.
  SemanticMapURL   TEXT,
  PictureURL       TEXT, -- relative path.
  VocabDescription TEXT,
  VocabCountOrder  INTEGER,
  VocabDeleted     TEXT,
  ParentVocabID    INTEGER REFERENCES Vocabulary( VocabID)
  );

--create index vocabindex on vocabulary (vocabid);
CREATE INDEX vocabAttIndex ON vocabulary (attributeid, vocabname);

/* As Archents exist, so do relationships. Relationships serve to link ArchEnts together and to collect the subjective expertise of
 * the archaeologist in such a way that it does not contaminate the "facts".
 */

CREATE TABLE RelnType (
  RelnTypeID          INTEGER PRIMARY KEY,
  RelnTypeName        TEXT NOT NULL, -- Equivalent to table-name
  RelnTypeDescription TEXT, -- human description explaining purpose of the relationship type
  RelnTypeCategory    TEXT, -- This is, actually, important. It identifies the *category* of relationship-meatphor: hierarchial, container, or bidirectional.
  Parent              TEXT, -- This is the text string that serves to identify, for categories of type hierarchial, the "participatesverb"
								  -- that identifies a parent. It should be possible, using this, to select all parents in a specific
								  -- hierarchial relationship by constraining the search to this term.
  Child               TEXT -- As above, but for the other side of the hierarchial relationship. Relationships of other category/metaphor do not need
								 -- participation verbs
);


CREATE TABLE IdealAEnt (
  AEntTypeID      INTEGER REFERENCES AEntType,
  AttributeID     INTEGER REFERENCES AttributeKey,
  AEntDescription TEXT, -- human description
  IsIdentifier    BOOLEAN, -- This is the means by which a designer identifies an attribute in a given aentType as an identifier.
									 -- an identifier in this instance does not enforce not null nor uniqueness. It merely serves to identify
									 -- what subset of rows
  MinCardinality  INTEGER, -- It is theoretically possible to use these to power script-level validation
  MaxCardinality  INTEGER,
  AEntCountOrder  INTEGER,
  CONSTRAINT IdealAEntPK PRIMARY KEY (AEntTypeID, AttributeID)
);

CREATE TABLE IdealReln (
  RelnTypeID      INTEGER REFERENCES RelnType,
  AttributeID     INTEGER REFERENCES AttributeKey,
  RelnDescription TEXT, -- human description
  IsIdentifier    BOOLEAN, -- as above
  MinCardinality  INTEGER,
  MaxCardinality  INTEGER,
  CONSTRAINT IdealRelnPK PRIMARY KEY (RelnTypeID, AttributeID)
);

CREATE TABLE ArchEntity (
  UUID                 INTEGER NOT NULL,
  AEntTimestamp        DATETIME DEFAULT CURRENT_TIMESTAMP,
  UserID               INTEGER NOT NULL REFERENCES User,
  DOI                  TEXT,
  AEntTypeID           INTEGER NOT NULL REFERENCES AEntType,
  Deleted              BOOLEAN,
  VersionNum           INTEGER REFERENCES Version,
  isDirty              BOOLEAN, --validation "dirty bit"
  isDirtyReason        TEXT,
  isForked             BOOLEAN, -- fork signalling
  ParentTimestamp      DATETIME, -- nominally we'd reference Archent here, but just no. No.
  GeoSpatialColumnType TEXT, -- for humans to signal the contents of the geometry column. Not really used.
  CONSTRAINT ArchEntityPK PRIMARY KEY (UUID, AEntTimestamp, UserID)
);

CREATE INDEX aentindex ON archentity (uuid);
CREATE INDEX aenttimeindex ON archentity (uuid, aenttimestamp);

CREATE TABLE AentValue (
  UUID            INTEGER NOT NULL,
  ValueTimestamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
  UserID          INTEGER NOT NULL REFERENCES User,
  AttributeID     TEXT    NOT NULL REFERENCES AttributeKey,
  VocabID         INTEGER REFERENCES Vocabulary,
  Measure         TEXT,
  FreeText        TEXT,
  Certainty       REAL,
  Deleted         BOOLEAN,
  VersionNum      INTEGER REFERENCES Version,
  isDirty         BOOLEAN, --validation "dirty bit"
  isDirtyReason   TEXT,
  isForked        BOOLEAN, -- fork signalling
  ParentTimestamp DATETIME -- nominally we'd reference Archent here, but just no. No.
  , UNIQUE (UUID, ValueTimestamp, UserID, AttributeID, VocabID, Measure, FreeText, Certainty, Deleted)
  ON CONFLICT REPLACE
);


CREATE INDEX aentvalueindex ON AentValue (uuid, attributeid, valuetimestamp DESC);
CREATE INDEX aentvaluelookupindex ON AentValue (uuid, attributeid, valuetimestamp DESC, freetext, vocabid, measure);


CREATE TABLE Relationship (
  RelationshipID       INTEGER NOT NULL,
  RelnTimestamp        DATETIME DEFAULT CURRENT_TIMESTAMP,
  UserID               INTEGER NOT NULL REFERENCES User,
  RelnTypeID           INTEGER NOT NULL REFERENCES RelnType,
  Deleted              BOOLEAN,
  VersionNum           INTEGER REFERENCES Version,
  isDirty              BOOLEAN, --validation "dirty bit"
  isDirtyReason        TEXT,
  isForked             BOOLEAN, -- fork signalling
  ParentTimestamp      DATETIME, -- nominally we'd reference Archent here, but just no. No.
  GeoSpatialColumnType TEXT, -- for humans to signal the contents of the geometry column. Not really used.
  CONSTRAINT RelnPK PRIMARY KEY (RelationshipID, RelnTimestamp, UserID)
);

CREATE INDEX relnindex ON relationship (relationshipid);

CREATE TABLE RelnValue (
  RelationshipID     INTEGER NOT NULL,
  RelnValueTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  UserID             INTEGER NOT NULL REFERENCES User,
  AttributeID        TEXT    NOT NULL REFERENCES AttributeKey,
  VocabID            INTEGER REFERENCES Vocabulary,
  Freetext           TEXT,
  Certainty          REAL,
  Deleted            BOOLEAN,
  VersionNum         INTEGER REFERENCES Version,
  isDirty            BOOLEAN, --validation "dirty bit"
  isDirtyReason      TEXT,
  isForked           BOOLEAN, -- fork signalling
  ParentTimestamp    DATETIME -- nominally we'd reference Archent here, but just no. No.
  , UNIQUE (RelationshipID, RelnValueTimestamp, UserID, AttributeID, VocabID, FreeText, Certainty, Deleted)
  ON CONFLICT REPLACE
);

CREATE INDEX relnvalueindex ON relnvalue (relationshipid, attributeid, relnvaluetimestamp DESC);

CREATE TABLE AEntReln (
  UUID              INTEGER NOT NULL,
  RelationshipID    INTEGER NOT NULL,
  UserID            INTEGER NOT NULL REFERENCES User,
  AEntRelnTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  ParticipatesVerb  TEXT,
  Deleted           BOOLEAN,
  VersionNum        INTEGER REFERENCES Version,
  isDirty           BOOLEAN, --validation "dirty bit"
  isDirtyReason     TEXT,
  isForked          BOOLEAN, -- fork signalling
  ParentTimestamp   DATETIME -- nominally we'd reference Archent here, but just no. No.
);

CREATE INDEX aentrelnindex ON aentreln (uuid, relationshipid, AEntRelnTimestamp);

--SELECT InitSpatialMetaData();

SELECT
  AddGeometryColumn('ArchEntity', 'GeoSpatialColumn', 4326, 'GEOMETRYCOLLECTION', 'XY');
SELECT
  AddGeometryColumn('Relationship', 'GeoSpatialColumn', 4326, 'GEOMETRYCOLLECTION', 'XY');

-- create spatial indexes
SELECT
  CreateSpatialIndex('ArchEntity', 'GeoSpatialColumn');
SELECT
  CreateSpatialIndex('Relationship', 'GeoSpatialColumn');

DROP VIEW IF EXISTS latestNonDeletedArchent;
CREATE VIEW latestNonDeletedArchent AS
  SELECT
    *,
    substr(uuid, 7) AS epoch
  FROM archentity
    JOIN (SELECT
            uuid,
            max(aenttimestamp) AS aenttimestamp
          FROM archentity
          GROUP BY uuid) USING (uuid, aenttimestamp)
  WHERE deleted IS NULL;

DROP VIEW IF EXISTS latestNonDeletedAentValue;
CREATE VIEW IF NOT EXISTS latestNonDeletedAentValue AS
  SELECT
    *
  FROM aentvalue
    JOIN (SELECT
            uuid,
            attributeid,
            max(valuetimestamp) AS ValueTimestamp
          FROM aentvalue
          GROUP BY uuid, attributeid) USING (uuid, attributeid, valuetimestamp)
  WHERE deleted IS NULL;

DROP VIEW IF EXISTS latestNonDeletedArchEntIdentifiers;
CREATE VIEW IF NOT EXISTS latestNonDeletedArchEntIdentifiers AS
  SELECT
    *
  FROM latestNonDeletedAentValue
    JOIN latestNonDeletedArchent USING (uuid)
    JOIN aenttype USING (aenttypeid)
    JOIN idealaent USING (aenttypeid, attributeid)
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (attributeid, vocabid)
  WHERE isIdentifier = 'true';


DROP VIEW IF EXISTS latestAllArchEntIdentifiers;
CREATE VIEW IF NOT EXISTS latestAllArchEntIdentifiers AS
  SELECT
    *,
    substr(uuid, 7) AS epoch
  FROM archentity
    JOIN (SELECT
            uuid,
            max(aenttimestamp) AS aenttimestamp
          FROM archentity
          GROUP BY uuid) USING (uuid, aenttimestamp)
    JOIN aentvalue USING (uuid)
    JOIN (SELECT
            uuid,
            attributeid,
            max(valuetimestamp) AS ValueTimestamp
          FROM aentvalue
          GROUP BY uuid, attributeid) USING (uuid, attributeid, valuetimestamp)
    JOIN aenttype USING (aenttypeid)
    JOIN idealaent USING (aenttypeid, attributeid)
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (attributeid, vocabid)
  WHERE isIdentifier = 'true';


DROP VIEW IF EXISTS latestNonDeletedRelationship;
CREATE VIEW latestNonDeletedRelationship AS
  SELECT
    *
  FROM relationship
    JOIN (SELECT
            relationshipid,
            max(relntimestamp) AS relntimestamp
          FROM relationship
          GROUP BY relationshipid) USING (relationshipid, relntimestamp)
  WHERE deleted IS NULL;

DROP VIEW IF EXISTS latestNonDeletedRelnValue;
CREATE VIEW latestNonDeletedRelnValue AS
  SELECT
    *
  FROM relnvalue
    JOIN (SELECT
            relationshipid,
            attributeid,
            max(relnvaluetimestamp) AS relnvaluetimestamp
          FROM relnvalue
          GROUP BY relationshipid, attributeid) USING (relationshipid, attributeid, relnvaluetimestamp)
  WHERE deleted IS NULL;


DROP VIEW IF EXISTS latestNonDeletedRelnIdentifiers;
CREATE VIEW latestNonDeletedRelnIdentifiers AS
  SELECT
    *
  FROM latestNonDeletedRelationship
    JOIN relntype USING (relntypeid)
    JOIN idealreln USING (relntypeid)
    JOIN latestNonDeletedRelnValue USING (relationshipid, attributeid)
    JOIN attributekey USING (attributeid)
    LEFT OUTER JOIN vocabulary USING (attributeid, vocabid)
  WHERE isIdentifier = 'true';


DROP VIEW IF EXISTS latestAllRelationshipIdentifiers;
CREATE VIEW latestAllRelationshipIdentifiers AS
  SELECT
    *
  FROM relationship
    JOIN (SELECT
            relationshipid,
            max(relntimestamp) AS relntimestamp
          FROM relationship
          GROUP BY relationshipid
      ) USING (relationshipid, relntimestamp)
    JOIN idealreln USING (relntypeid)
    JOIN relnvalue USING (relationshipid, attributeid)
    JOIN (SELECT
            relationshipid,
            attributeid,
            max(relnvaluetimestamp) AS relnvaluetimestamp
          FROM relnvalue
          GROUP BY relationshipid, attributeid) USING (relationshipid, attributeid, relnvaluetimestamp)
    LEFT OUTER JOIN vocabulary USING (attributeid, vocabid)
  WHERE isIdentifier = 'true';

DROP VIEW IF EXISTS latestNonDeletedAentReln;
CREATE VIEW latestNonDeletedAentReln AS
  SELECT
    *
  FROM
    aentreln
    JOIN (SELECT
            uuid,
            relationshipid,
            max(aentrelntimestamp) AS aentrelntimestamp
          FROM aentreln
          GROUP BY uuid, relationshipid) USING (uuid, relationshipid, aentrelntimestamp)
  WHERE deleted IS NULL;