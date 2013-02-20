
PRAGMA foreign_keys = off;

PRAGMA page_size = 4096;
PRAGMA cache_size = 400000;
vacuum;

CREATE TABLE Version (
  VersionNum           INTEGER NOT NULL,
  UploadTimestamp      DATETIME DEFAULT CURRENT_TIMESTAMP,
  UserID               INTEGER,
  IsMerged             INTEGER
);

CREATE TABLE User (
	UserID               INTEGER NOT NULL,
	FName                TEXT,
	LName                TEXT
 );

CREATE TABLE AEntType (
	AEntTypeID            TEXT NOT NULL,
	AEntTypeName		  TEXT,
	AEntTypeCategory	  TEXT,
	AEntTypeDescription   TEX
 );

CREATE TABLE AttributeKey (
	AttributeID          TEXT NOT NULL,
	AttributeType		 TEXT,
	AttributeName        TEXT,
	AttributeDescription TEXT
 );

create index atkey on attributekey(attributeid);
create index atkeyname on attributekey(attributename);


CREATE TABLE Vocabulary (
	VocabID              INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	VocabName          	 TEXT,
	SemanticMapURL	     TEXT,
	PictureURL			 TEXT
 );

create index vocabindex on vocabulary (vocabid);
create index vocabattindex on vocabulary (attributeid, vocabname);


CREATE TABLE RelnType (
	RelnTypeID           INTEGER NOT NULL,
	RelnTypeName		 TEXT,
	RelnTypeDescription  TEXT,
	RelnTypeCategory	 TEXT,
	Parent				 TEXT,
	Child				 TEXT
 );

CREATE TABLE IdealAEnt (
	AEntTypeID           TEXT NOT NULL,
	AttributeID          TEXT NOT NULL,
	AEntDescription      TEXT,
	IsIdentifier		 BOOLEAN,
	MinCardinality		 INTEGER,
	MaxCardinality		 INTEGER
 );

CREATE TABLE IdealReln (
	RelnTypeID           INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	RelnDescription      TEXT,
	IsIdentifier		 BOOLEAN,
	MinCardinality		 INTEGER,
	MaxCardinality		 INTEGER
 );

CREATE TABLE ArchEntity (
	UUID                 integer NOT NULL,
	AEntTimestamp        DATETIME DEFAULT CURRENT_TIMESTAMP,
	UserID               INTEGER,
	DOI                  TEXT,
	AEntTypeID           TEXT,
	Deleted				 BOOLEAN,
	GeoSpatialColumnType TEXT,
	VersionNum           INTEGER
 );

create index aentindex on archentity (uuid);

CREATE TABLE AEntValue (
	UUID                 integer NOT NULL,
	ValueTimestamp       DATETIME DEFAULT CURRENT_TIMESTAMP,
	VocabID              INTEGER,
	AttributeID          TEXT NOT NULL,
	Measure              INT,
	FreeText             TEXT,
	Certainty            REAL,
	Deleted				 BOOLEAN,
	VersionNum           INTEGER
 );

create index aentvalueindex on AentValue (uuid, attributeid, valuetimestamp desc);

CREATE TABLE Relationship (
	RelationshipID       INTEGER NOT NULL,
	UserID               INTEGER NOT NULL,
	RelnTimestamp        DATETIME DEFAULT CURRENT_TIMESTAMP,
	GeoSpatialColumnType TEXT,
	Deleted				 BOOLEAN,
	RelnTypeID           INTEGER NOT NULL,
	VersionNum           INTEGER
 );

create index relnindex on relationship (relationshipid);

CREATE TABLE AEntReln (
	UUID                 INTEGER NOT NULL,
	RelationshipID       INTEGER NOT NULL,
	ParticipatesVerb     TEXT,
	Deleted				 BOOLEAN,
	AEntRelnTimestamp    DATETIME DEFAULT CURRENT_TIMESTAMP,
	VersionNum           INTEGER
 );

create index aentrelnindex on aentreln (uuid, relationshipid, AEntRelnTimestamp);

CREATE TABLE RelnValue (
	RelationshipID       INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	VocabID              INTEGER,
	RelnValueTimestamp   DATETIME DEFAULT CURRENT_TIMESTAMP,
	Deleted				 BOOLEAN,
	Certainty            REAL,
	Freetext             TEXT,
	VersionNum           INTEGER
 );

create index relnvalueindex on relnvalue (relationshipid, attributeid, relnvaluetimestamp desc);

SELECT AddGeometryColumn('ArchEntity', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');
SELECT AddGeometryColumn('Relationship', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');
