PRAGMA foreign_keys = off;
  
PRAGMA page_size = 1024;
PRAGMA cache_size = 800000;
vacuum;
  
CREATE TABLE User ( 
    UserID               INTEGER NOT NULL,
    FName                TEXT,
    LName                TEXT,
    CONSTRAINT Pk_User PRIMARY KEY ( UserID )
 );
 
CREATE TABLE ObservationType ( 
    ObsTypeID            INTEGER NOT NULL,
    ObsTypeDescription   TEXT,
    CONSTRAINT Pk_ObservationType PRIMARY KEY ( ObsTypeID )
 );
 
CREATE TABLE AttributeKey ( 
    AttributeID          INTEGER NOT NULL,
    AttributeName        TEXT,
    AttributeDescription TEXT,
    CONSTRAINT Pk_AttributeKey PRIMARY KEY ( AttributeID )
 );
 
CREATE TABLE Vocabulary ( 
    VocabID              INTEGER NOT NULL,
    AttributeID          INTEGER NOT NULL,
    ConceptName          TEXT,
    CONSTRAINT Pk_Vocabulary PRIMARY KEY ( VocabID ),
    FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID ) 
 );
 
CREATE TABLE RelnType ( 
    RelnTypeID           INTEGER NOT NULL,
    RelnTypeDescription  TEXT,
    CONSTRAINT Pk_RelnType PRIMARY KEY ( RelnTypeID )
 );
 
CREATE TABLE IdealObs ( 
    ObsTypeID            INTEGER NOT NULL,
    AttributeID          INTEGER NOT NULL,
    Description          TEXT,
    CONSTRAINT Idx_IdealObs PRIMARY KEY ( ObsTypeID, AttributeID ),
    FOREIGN KEY ( ObsTypeID ) REFERENCES ObservationType( ObsTypeID ) ,
    FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID ) 
 );
 
CREATE TABLE IdealReln ( 
    RelnTypeID           INTEGER NOT NULL,
    AttributeID          INTEGER NOT NULL,
    Description          TEXT,
    CONSTRAINT Idx_IdealReln PRIMARY KEY ( RelnTypeID, AttributeID ),
    FOREIGN KEY ( RelnTypeID ) REFERENCES RelnType( RelnTypeID ) ,
    FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID ) 
 );
 
CREATE TABLE UnitOfObservation ( 
    UUID                 text NOT NULL,
    ObsTimestamp         DATETIME DEFAULT CURRENT_TIMESTAMP,
    UserID               INTEGER,
    DOI                  TEXT,
    ObsTypeID            INTEGER,
    --GeoSpatialColumn     BLOB,
    GeoSpatialColumnType TEXT,
    CONSTRAINT Idx_UnitOfObservation PRIMARY KEY ( UUID, ObsTimestamp ),
    FOREIGN KEY ( UserID ) REFERENCES User( UserID ) ,
    FOREIGN KEY ( ObsTypeID ) REFERENCES ObservationType( ObsTypeID ) 
 );
 
CREATE TABLE ObservationValue ( 
    UUID                 text NOT NULL,
    ValueTimestamp       DATETIME DEFAULT CURRENT_TIMESTAMP,
    VocabID              INTEGER,
    AttributeID          INTEGER NOT NULL,
    Measure              INT,
    FreeText             TEXT,
    Certainty            REAL,
    FOREIGN KEY ( UUID ) REFERENCES UnitOfObservation( UUID ) ,
    FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID ) ,
    FOREIGN KEY ( VocabID ) REFERENCES Vocabulary( VocabID ) 
 );
 
CREATE TABLE Relationship ( 
    RelationshipID       INTEGER NOT NULL,
    UserID               INTEGER NOT NULL,
    RelnTimestamp        DATETIME NOT NULL,
    --GeospatialColumn     BLOB,
    GeoSpatialColumnType TEXT,
    RelnTypeID           INTEGER NOT NULL,
    CONSTRAINT Pk_Relationship PRIMARY KEY ( RelationshipID, UserID, RelnTimestamp ),
    FOREIGN KEY ( RelnTypeID ) REFERENCES RelnType( RelnTypeID ) ,
    FOREIGN KEY ( UserID ) REFERENCES User( UserID ) 
 );
 
CREATE TABLE ObsReln ( 
    UUID                 INTEGER NOT NULL,
    RelationshipID       INTEGER NOT NULL,
    ParticipatesVerb     TEXT,
    ObsRelnTimestamp     DATETIME,
    CONSTRAINT Idx_ObsReln PRIMARY KEY ( RelationshipID, UUID ),
    FOREIGN KEY ( RelationshipID ) REFERENCES Relationship( RelationshipID ) ,
    FOREIGN KEY ( UUID ) REFERENCES UnitOfObservation( UUID ) 
 );
 
CREATE TABLE RelnValue ( 
    RelationshipID       INTEGER NOT NULL,
    AttributeID          INTEGER NOT NULL,
    VocabID              INTEGER NOT NULL,
    RelnValueTimestamp   DATETIME NOT NULL,
    Freetext             TEXT,
    FOREIGN KEY ( RelationshipID ) REFERENCES Relationship( RelationshipID ) ,
    FOREIGN KEY ( AttributeID ) REFERENCES AttributeKey( AttributeID ) ,
    FOREIGN KEY ( VocabID ) REFERENCES Vocabulary( VocabID ) 
 );
