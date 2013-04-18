require 'spec_helper'
require 'tempfile'
require 'sqlite3'
load File.expand_path("#{Rails.root}/spec/tools/helpers/database_generator_spec_helper.rb", __FILE__)

describe Database do

  it "Generates and Parses database" do
    tempfile = Tempfile.new('db.sqlite3')
    Database.generate_database(tempfile.path, Rails.root.join('spec', 'assets', 'data_schema.xml').to_s)
    db = SpatialiteDB.new(tempfile.path)
    result = db.execute("select count(*) || 'ideal arch ent' from idealAEnt union select count(*) || 'ideal reln'  from idealreln union select count(*) || 'aent type' from aenttype union select count(*) || 'relntype' from relntype union select count(*) || 'attributekey'  from attributekey;")
    result[0].should == ["2aent type"]
    result[1].should == ["30attributekey"]
    result[2].should == ["3ideal reln"]
    result[3].should == ["3relntype"]
    result[4].should == ["46ideal arch ent"]
    tempfile.unlink
  end

  it "Generates and Parses data_schema.xml with single qoutes" do
    tempfile = Tempfile.new('db.sqlite3')
    Database.generate_database(tempfile.path, Rails.root.join('spec', 'assets', 'pottery.xml').to_s)
    tempfile.unlink
  end

  describe "Merging databases" do
    it "Empty database and Empty database" do
      db1 = create_empty_database()
      db2 = create_empty_database()

      Database.merge_database(nil, db1.path, db2.path,1)

      is_database_empty(db1).should be_true

      db1.unlink
      db2.unlink
    end

    it "Empty database and Full database" do
      version = 1

      db1 = create_empty_database()
      db2 = create_full_database(version)

      Database.merge_database(nil, db1.path, db2.path, version)

      is_database_same(db1, db2).should be_true

      db1.unlink
      db2.unlink
    end

    it "Full database and Empty database" do
      version = 1

      db1 = create_full_database(version)
      db2 = create_empty_database()

      backup_db1 = backup_database(db1)

      Database.merge_database(nil, db1.path, db2.path, version)

      is_database_same(backup_db1, db1).should be_true

      db1.unlink
      db2.unlink
      backup_db1.unlink
    end

    it "Full database and Full database" do
      version = 1

      db1 = create_full_database(version)
      db2 = create_full_database() # version doesn't matter

      backup_db1 = backup_database(db1)

      Database.merge_database(nil, db1.path, db2.path, version)

      is_database_merged(db1, backup_db1, db2).should be_true

      db1.unlink
      db2.unlink
      backup_db1.unlink
    end

    it "Does not insert duplicate records" do
      version = 1
      db1 = create_full_database(version)

      backup_db1 = backup_database(db1)

      Database.merge_database(nil, db1.path, backup_db1.path, version)

      is_database_same(backup_db1, db1).should be_true

      db1.unlink
      backup_db1.unlink
    end

    it "Merge rows must have correct version number" do
      db1 = create_empty_database()
      db2 = create_full_database(nil, nil, 0) #version doesn't matter
      db3 = create_full_database(nil, nil, 1000) #version doesn't matter

      Database.merge_database(nil, db1.path, db2.path, 1)
      Database.merge_database(nil, db1.path, db3.path, 2)

      is_version_database_same(db1, db2, 1).should be_true
      is_version_database_same(db1, db3, 2).should be_true

      db1.unlink
      db2.unlink
      db3.unlink
    end

  end

end
