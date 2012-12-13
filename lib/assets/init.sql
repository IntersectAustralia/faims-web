PRAGMA foreign_keys = off;

PRAGMA page_size = 4096;
vacuum;

CREATE TABLE User (
	UserID               INTEGER NOT NULL,
	FName                TEXT,
	LName                TEXT,
	CONSTRAINT Pk_User PRIMARY KEY ( UserID )
 );

CREATE TABLE AEntType (
	AEntTypeID            TEXT NOT NULL,
	AEntTypeName		  TEXT,
	AEntTypeCategory	  TEXT,
	AEntTypeDescription   TEXT,
	CONSTRAINT Pk_AEntTypeID PRIMARY KEY ( AEntTypeID )
 );

CREATE TABLE AttributeKey (
	AttributeID          TEXT NOT NULL,
	AttributeType		 Text,
	AttributeName        TEXT,
	AttributeDescription TEXT,
	CONSTRAINT Pk_AttributeKey PRIMARY KEY ( AttributeID )
 );

CREATE TABLE Vocabulary (
	VocabID              INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	VocabName          	 TEXT,
	CONSTRAINT Pk_Vocabulary PRIMARY KEY ( VocabID ),
	FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID )
 );

CREATE TABLE RelnType (
	RelnTypeID           INTEGER NOT NULL,
	RelnTypeName		 TEXT,
	RelnTypeDescription  TEXT,
	RelnTypeCategory	 TEXT,
	Parent				 TEXT,
	Child				 TEXT,
	CONSTRAINT Pk_RelnType PRIMARY KEY ( RelnTypeID )
 );

CREATE TABLE IdealAEnt (
	AEntTypeID           TEXT NOT NULL,
	AttributeID          TEXT NOT NULL,
	Description          TEXT,
	CONSTRAINT Idx_IdealObs PRIMARY KEY ( AEntTypeID, AttributeID ),
	FOREIGN KEY ( AEntTypeID ) REFERENCES AEntType( AEntTypeID ) ,
	FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID )
 );

CREATE TABLE IdealReln (
	RelnTypeID           INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	Description          TEXT,
	CONSTRAINT Idx_IdealReln PRIMARY KEY ( RelnTypeID, AttributeID ),
	FOREIGN KEY ( RelnTypeID ) REFERENCES RelnType( RelnTypeID ) ,
	FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID )
 );

CREATE TABLE ArchEntity (
	UUID                 integer NOT NULL,
	ObsTimestamp         DATETIME DEFAULT CURRENT_TIMESTAMP,
	UserID               INTEGER,
	DOI                  TEXT,
	AEntTypeID           TEXT,
	GeoSpatialColumnType TEXT,
	CONSTRAINT Idx_UnitOfObservation PRIMARY KEY ( UUID, ObsTimestamp ),
	FOREIGN KEY ( UserID ) REFERENCES User( UserID ) ,
	FOREIGN KEY ( AEntTypeID ) REFERENCES AEntType( AEntTypeID )
 );

CREATE TABLE AEntValue (
	UUID                 integer NOT NULL,
	ValueTimestamp       DATETIME DEFAULT CURRENT_TIMESTAMP,
	VocabID              INTEGER,
	AttributeID          TEXT NOT NULL,
	Measure              INT,
	FreeText             TEXT,
	Certainty            REAL,
	FOREIGN KEY ( UUID ) REFERENCES ArchEntity( UUID ) ,
	FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID ) ,
	FOREIGN KEY ( VocabID ) REFERENCES Vocabulary( VocabID )
 );

CREATE TABLE Relationship (
	RelationshipID       INTEGER NOT NULL,
	UserID               INTEGER NOT NULL,
	RelnTimestamp        DATETIME NOT NULL,
	GeoSpatialColumnType TEXT,
	RelnTypeID           INTEGER NOT NULL,
	CONSTRAINT Pk_Relationship PRIMARY KEY ( RelationshipID, UserID, RelnTimestamp ),
	FOREIGN KEY ( RelnTypeID ) REFERENCES RelnType( RelnTypeID ) ,
	FOREIGN KEY ( UserID ) REFERENCES User( UserID )
 );

CREATE TABLE AEntReln (
	UUID                 INTEGER NOT NULL,
	RelationshipID       INTEGER NOT NULL,
	ParticipatesVerb     TEXT,
	ObsRelnTimestamp     DATETIME,
	CONSTRAINT Idx_ObsReln PRIMARY KEY ( RelationshipID, UUID ),
	FOREIGN KEY ( RelationshipID ) REFERENCES Relationship( RelationshipID ) ,
	FOREIGN KEY ( UUID ) REFERENCES ArchEntity( UUID )
 );

CREATE TABLE RelnValue (
	RelationshipID       INTEGER NOT NULL,
	AttributeID          TEXT NOT NULL,
	VocabID              INTEGER NOT NULL,
	RelnValueTimestamp   DATETIME NOT NULL,
	Freetext             TEXT,
	FOREIGN KEY ( RelationshipID ) REFERENCES Relationship( RelationshipID ) ,
	FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID ) ,
	FOREIGN KEY ( VocabID ) REFERENCES Vocabulary( VocabID )
 );

SELECT AddGeometryColumn('ArchEntity', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');
SELECT AddGeometryColumn('Relationship', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');