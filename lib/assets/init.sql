PRAGMA page_size = 4096;
PRAGMA cache_size = 400000;
vacuum;

-- The user table is incomplete. It however, holds user information.
CREATE TABLE User (
	UserID					INTEGER PRIMARY KEY,
	FName               	TEXT NOT NULL,
	LName               	TEXT NOT NULL,
	Email                 TEXT NOT NULL
 );


-- the version table controle upload synchronization
CREATE TABLE Version (
  VersionNum           		INTEGER PRIMARY KEY,
  UploadTimestamp      		DATETIME DEFAULT CURRENT_TIMESTAMP,
  UserID               		INTEGER REFERENCES User,
  IsMerged             		INTEGER
);


/* the start of the core archentity definition.
 * ArchEnts are intended to be containers of "fact", the AentType
 * defines a platonic ideal instance of a specific /type/ of archentity,
 * in combination of idealAent. (which serves to identify the "ideal" columns of
 * the nominal entity. AentType and IdealAent serve the equivalent role of a create
 * table statement in DML land.
 */
CREATE TABLE AEntType (
	AEntTypeID				INTEGER PRIMARY KEY,
	AEntTypeName			TEXT NOT NULL, -- table name
	AEntTypeCategory		TEXT, -- I'm honestly not sure what we use this for.
	AEntTypeDescription 	TEXT -- human description
 );


/* the attributekey table serves to identify the possible columns across the
 * database. It is a central repository of columns by virtue of DKNF. Column
 * level metadata also goes here.
 */

CREATE TABLE AttributeKey (
	AttributeID           	INTEGER PRIMARY KEY,
	AttributeType		 	TEXT, -- this is typing for external tools. It has no bearing internally
	AttributeName         	TEXT NOT NULL, -- effectively column name
	AttributeDescription  	TEXT -- human-entered description for the "column"
 );

-- TODO tweak indexes for performance
-- create index atkey on attributekey(attributeid);
create index atkeyname on attributekey(attributename, attributeid);

/* The vocabulary table is the "lookup" table for the database.
 * Cruically, vocabNames can be mapped to our Arch16n infrastructure. {this} represents a standard string replacement expression. It will
 * look in the arch16n file and replace {this} with whatever the mapping is.
 * Picture URL is a *relative* path to define a picture dictionary.
 * Semantic Map URL is the start of our attempt to represent semantic names (like cidoc-crm). It however, has not recieved any dev time.
 */

CREATE TABLE Vocabulary (
	VocabID              	INTEGER PRIMARY KEY,
	AttributeID          	INTEGER NOT NULL REFERENCES AttributeKey,
	VocabName          	 	TEXT NOT NULL, -- This is the human-visible part of vocab that forms lookup tables. It is likely to be Arch16nized.
	SemanticMapURL	     	TEXT,
	PictureURL				TEXT, -- relative path.
	VocabDescription	     	TEXT
 );

--create index vocabindex on vocabulary (vocabid);
create index vocabAttIndex on vocabulary (attributeid, vocabname);

/* As Archents exist, so do relationships. Relationships serve to link ArchEnts together and to collect the subjective expertise of
 * the archaeologist in such a way that it does not contaminate the "facts".
 */

CREATE TABLE RelnType (
	RelnTypeID           	INTEGER PRIMARY KEY,
	RelnTypeName		 	TEXT NOT NULL, -- Equivalent to table-name
	RelnTypeDescription  	TEXT, -- human description explaining purpose of the relationship type
	RelnTypeCategory	 	TEXT, -- This is, actually, important. It identifies the *category* of relationship-meatphor: hierarchial, container, or bidirectional.
	Parent				 	TEXT, -- This is the text string that serves to identify, for categories of type hierarchial, the "participatesverb"
								  -- that identifies a parent. It should be possible, using this, to select all parents in a specific
								  -- hierarchial relationship by constraining the search to this term.
	Child				 	TEXT -- As above, but for the other side of the hierarchial relationship. Relationships of other category/metaphor do not need
								 -- participation verbs
 );


CREATE TABLE IdealAEnt (
	AEntTypeID           	INTEGER REFERENCES AEntType,
	AttributeID          	INTEGER REFERENCES AttributeKey,
	AEntDescription      	TEXT, -- human description
	IsIdentifier		 	BOOLEAN, -- This is the means by which a designer identifies an attribute in a given aentType as an identifier.
									 -- an identifier in this instance does not enforce not null nor uniqueness. It merely serves to identify
									 -- what subset of rows
	MinCardinality		 	INTEGER, -- It is theoretically possible to use these to power script-level validation
	MaxCardinality		 	INTEGER,
	CONSTRAINT IdealAEntPK PRIMARY KEY(AEntTypeID, AttributeID)
 );

CREATE TABLE IdealReln (
	RelnTypeID           	INTEGER REFERENCES RelnType,
	AttributeID          	INTEGER REFERENCES AttributeKey,
	RelnDescription      	TEXT, -- human description
	IsIdentifier		 	BOOLEAN, -- as above
	MinCardinality		 	INTEGER,
	MaxCardinality		 	INTEGER,
	CONSTRAINT IdealRelnPK PRIMARY KEY(RelnTypeID, AttributeID)

 );

CREATE TABLE ArchEntity (
	UUID                 	INTEGER NOT NULL,
	AEntTimestamp        	DATETIME DEFAULT CURRENT_TIMESTAMP,
	UserID               	INTEGER NOT NULL REFERENCES User,
	DOI                  	TEXT,
	AEntTypeID           	INTEGER NOT NULL REFERENCES AEntType,
	Deleted				 	BOOLEAN,
	VersionNum           	INTEGER REFERENCES Version,
	isDirty					BOOLEAN, --validation "dirty bit"
	isDirtyReason			TEXT,
	isForked				BOOLEAN, -- fork signalling
	ParentTimestamp			DATETIME, -- nominally we'd reference Archent here, but just no. No.
	GeoSpatialColumnType 	TEXT, -- for humans to signal the contents of the geometry column. Not really used.
	CONSTRAINT  ArchEntityPK PRIMARY KEY(UUID, AEntTimestamp, UserID)
 );

create index aentindex on archentity (uuid);
create index aenttimeindex on archentity (uuid, aenttimestamp);

CREATE TABLE AentValue (
	UUID                 	INTEGER NOT NULL,
	ValueTimestamp       	DATETIME DEFAULT CURRENT_TIMESTAMP,
	UserID				 	INTEGER NOT NULL REFERENCES User,
	AttributeID          	TEXT NOT NULL REFERENCES AttributeKey,
	VocabID              	INTEGER REFERENCES Vocabulary,
	Measure              	REAL,
	FreeText             	TEXT,
	Certainty            	REAL,
	Deleted				 	BOOLEAN,
	VersionNum           	INTEGER REFERENCES Version,
	isDirty					BOOLEAN, --validation "dirty bit"
	isDirtyReason			TEXT,
	isForked				BOOLEAN, -- fork signalling
	ParentTimestamp			DATETIME -- nominally we'd reference Archent here, but just no. No.
  , UNIQUE (UUID, ValueTimestamp, UserID, AttributeID, VocabID, Measure, FreeText, Certainty, Deleted) ON CONFLICT REPLACE
 );


create index aentvalueindex on AentValue (uuid, attributeid, valuetimestamp desc);

CREATE TABLE Relationship (
	RelationshipID       	INTEGER NOT NULL,
	RelnTimestamp        	DATETIME DEFAULT CURRENT_TIMESTAMP,
	UserID               	INTEGER NOT NULL REFERENCES User,
	RelnTypeID           	INTEGER NOT NULL REFERENCES RelnType,
	Deleted				 	BOOLEAN,
	VersionNum           	INTEGER REFERENCES Version,
	isDirty					BOOLEAN, --validation "dirty bit"
	isDirtyReason			TEXT,
	isForked				BOOLEAN, -- fork signalling
	ParentTimestamp			DATETIME, -- nominally we'd reference Archent here, but just no. No.
	GeoSpatialColumnType 	TEXT, -- for humans to signal the contents of the geometry column. Not really used.
	CONSTRAINT  RelnPK PRIMARY KEY(RelationshipID, RelnTimestamp, UserID)
 );

create index relnindex on relationship (relationshipid);

CREATE TABLE RelnValue (
	RelationshipID       	INTEGER NOT NULL,
	RelnValueTimestamp   	DATETIME DEFAULT CURRENT_TIMESTAMP,
	UserID					INTEGER NOT NULL REFERENCES User,
	AttributeID          	TEXT NOT NULL REFERENCES AttributeKey,
	VocabID              	INTEGER REFERENCES Vocabulary,
	Freetext             	TEXT,
	Certainty            	REAL,
	Deleted				 	BOOLEAN,
	VersionNum           	INTEGER REFERENCES Version,
	isDirty					BOOLEAN, --validation "dirty bit"
	isDirtyReason			TEXT,
	isForked				BOOLEAN, -- fork signalling
	ParentTimestamp			DATETIME -- nominally we'd reference Archent here, but just no. No.
	, UNIQUE (RelationshipID, RelnValueTimestamp, UserID, AttributeID, VocabID, FreeText, Certainty, Deleted) ON CONFLICT REPLACE
 );

create index relnvalueindex on relnvalue (relationshipid, attributeid, relnvaluetimestamp desc);

CREATE TABLE AEntReln (
	UUID                 	INTEGER NOT NULL,
	RelationshipID       	INTEGER NOT NULL,
	UserID					INTEGER NOT NULL REFERENCES User,
	AEntRelnTimestamp    	DATETIME DEFAULT CURRENT_TIMESTAMP,
	ParticipatesVerb     	TEXT,
	Deleted				 	BOOLEAN,
	VersionNum           	INTEGER REFERENCES Version,
	isDirty					BOOLEAN, --validation "dirty bit"
	isDirtyReason			TEXT,
	isForked				BOOLEAN, -- fork signalling
	ParentTimestamp			DATETIME -- nominally we'd reference Archent here, but just no. No.
 );

create index aentrelnindex on aentreln (uuid, relationshipid, AEntRelnTimestamp);

--SELECT InitSpatialMetaData();

SELECT AddGeometryColumn('ArchEntity', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');
SELECT AddGeometryColumn('Relationship', 'GeoSpatialColumn',   4326, 'GEOMETRYCOLLECTION', 'XY');

-- create spatial indexes
SELECT CreateSpatialIndex('ArchEntity', 'GeoSpatialColumn');
SELECT CreateSpatialIndex('Relationship', 'GeoSpatialColumn');

drop view if exists latestNonDeletedArchent;
create view latestNonDeletedArchent as
  select *, substr(uuid,7) as epoch
  from archentity
  JOIN (select uuid, max(aenttimestamp) as aenttimestamp
          from archentity
         group by uuid) USING (uuid, aenttimestamp)
  where deleted is null;

drop view if exists latestNonDeletedAentValue;
create view if not exists latestNonDeletedAentValue as
  select *
  from aentvalue
  JOIN (select uuid, attributeid, max(valuetimestamp) as ValueTimestamp
        from aentvalue
        group by uuid, attributeid) USING (uuid, attributeid, valuetimestamp)
  where deleted is null;

drop view if exists latestNonDeletedArchEntIdentifiers;
create view if not exists latestNonDeletedArchEntIdentifiers as
  select *
  from latestNonDeletedAentValue
  JOIN latestNonDeletedArchent USING (uuid)
  JOIN aenttype using (aenttypeid)
  JOIN idealaent using (aenttypeid, attributeid)
  join attributekey using (attributeid)
  left outer join vocabulary using (attributeid, vocabid)
 WHERE isIdentifier = 'true';


drop view if exists latestAllArchEntIdentifiers;
create view if not exists latestAllArchEntIdentifiers as
  select *, substr(uuid,7) as epoch
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
 WHERE isIdentifier = 'true';


drop view if exists latestNonDeletedRelationship;
create view latestNonDeletedRelationship as
    select *
    from relationship
    JOIN (select relationshipid, max(relntimestamp) as relntimestamp
          from relationship
          group by relationshipid) USING (relationshipid, relntimestamp)
    where deleted is null;

drop view if exists latestNonDeletedRelnValue;
create view latestNonDeletedRelnValue as
  select *
  from relnvalue
  JOIN (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp
        from relnvalue
        group by relationshipid, attributeid) USING (relationshipid, attributeid, relnvaluetimestamp)
  where deleted is null;


drop view if exists latestNonDeletedRelnIdentifiers;
create view latestNonDeletedRelnIdentifiers as
  select *
  from latestNonDeletedRelationship
  join relntype using (relntypeid)
  join idealreln using (relntypeid)
  JOIN latestNonDeletedRelnValue using (relationshipid, attributeid)
  join attributekey using (attributeid)
  left outer join vocabulary using (attributeid, vocabid)
 WHERE isIdentifier = 'true';


drop view if exists latestAllRelationshipIdentifiers;
create view latestAllRelationshipIdentifiers as
  select *
  from  relationship JOIN (select relationshipid, max(relntimestamp) as relntimestamp
              from relationship
              group by relationshipid
              ) USING (relationshipid, relntimestamp)
        join idealreln using (relntypeid)
        join relnvalue using (relationshipid, attributeid)
        JOIN (select relationshipid, attributeid, max(relnvaluetimestamp) as relnvaluetimestamp
              from relnvalue
              group by relationshipid, attributeid) USING (relationshipid, attributeid, relnvaluetimestamp)
        LEFT OUTER JOIN vocabulary using (attributeid, vocabid);

drop view if exists latestNonDeletedAentReln;
create view latestNonDeletedAentReln as
  select * from
  aentreln join (select uuid, relationshipid, max(aentrelntimestamp) as aentrelntimestamp from aentreln group by uuid, relationshipid) using (uuid, relationshipid, aentrelntimestamp)
  where deleted is null;