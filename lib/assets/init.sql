
PRAGMA foreign_keys = off;

PRAGMA page_size = 4096;
PRAGMA cache_size = 400000;
vacuum;

CREATE TABLE User (
	UserID               INTEGER NOT NULL,
	FName                TEXT,
	LName                TEXT
 );

CREATE TABLE AEntType (
	AEntTypeID            TEXT NOT NULL,
	AEntTypeName		  TEXT,
	AEntTypeCategory	  TEXT,
	AEntTypeDescription   TEXT
 );

CREATE TABLE AttributeKey (
	AttributeID          TEXT NOT NULL,
	AttributeType		 Text,
	AttributeName        TEXT,
	AttributeDescription TEXT
 );

create index atkey on attributekey(attributeid);
create index atkeyname on attributekey(attributename);


CREATE TABLE Vocabulary (
	VocabID              INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	VocabName          	 TEXT
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
	MinCardinality		 INTEGER,
	MaxCardinality		 INTEGER
 );

CREATE TABLE IdealReln (
	RelnTypeID           INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	RelnDescription      TEXT,
	MinCardinality		 INTEGER,
	MaxCardinality		 INTEGER
 );

CREATE TABLE ArchEntity (
	UUID                 INTEGER NOT NULL,
	AEntTimestamp        DATETIME DEFAULT CURRENT_TIMESTAMP,
	UserID               INTEGER,
	DOI                  TEXT,
	AEntTypeID           TEXT,
	GeoSpatialColumnType TEXT
 );

create index aentindex on archentity (uuid);

CREATE TABLE AEntValue (
	UUID                 INTEGER NOT NULL,
	ValueTimestamp       DATETIME DEFAULT CURRENT_TIMESTAMP,
	VocabID              INTEGER,
	AttributeID          TEXT NOT NULL,
	Measure              INT,
	FreeText             TEXT,
	Certainty            REAL
 );

create index aentvalueindex on AentValue (uuid, attributeid, valuetimestamp desc);

CREATE TABLE Relationship (
	RelationshipID       INTEGER NOT NULL,
	UserID               INTEGER NOT NULL,
	RelnTimestamp        DATETIME DEFAULT CURRENT_TIMESTAMP,
	GeoSpatialColumnType TEXT,
	RelnTypeID           INTEGER NOT NULL
 );

create index relnindex on relationship (relationshipid);

CREATE TABLE AEntReln (
	UUID                 INTEGER NOT NULL,
	RelationshipID       INTEGER NOT NULL,
	ParticipatesVerb     TEXT,
	AEntRelnTimestamp    DATETIME DEFAULT CURRENT_TIMESTAMP
 );

create index aentrelnindex on aentreln (uuid, relationshipid, AEntRelnTimestamp);

CREATE TABLE RelnValue (
	RelationshipID       INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	VocabID              INTEGER,
	RelnValueTimestamp   DATETIME DEFAULT CURRENT_TIMESTAMP,
	Freetext             TEXT
 );

create index relnvalueindex on relnvalue (relationshipid, attributeid, relnvaluetimestamp desc);

SELECT AddGeometryColumn('ArchEntity', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');
SELECT AddGeometryColumn('Relationship', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');
