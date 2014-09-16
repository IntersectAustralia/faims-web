require 'spec_helper'
require Rails.root.join('spec/tools/helpers/database_generator_spec_helper')

describe Database do

  it 'Generates and Parses database' do
    tempfile = Tempfile.new('db.sqlite3')
    Database.generate_database(tempfile.path, Rails.root.join('spec', 'assets', 'data_schema.xml').to_s)
    db = SpatialiteDB.new(tempfile.path)
    result = db.execute("select count(*) || 'ideal arch ent' from idealAEnt union select count(*) || 'ideal reln'  from idealreln union select count(*) || 'aent type' from aenttype union select count(*) || 'relntype' from relntype union select count(*) || 'attributekey'  from attributekey;")
    result[0].should == ['2aent type']
    result[1].should == ['30attributekey']
    result[2].should == ['3ideal reln']
    result[3].should == ['3relntype']
    result[4].should == ['46ideal arch ent']
    tempfile.unlink
  end

  it 'Generates and Parses database' do
    tempfile = Tempfile.new('db.sqlite3')
    Database.generate_database(tempfile.path, Rails.root.join('spec', 'assets', 'data_schema_quote.xml').to_s)
    db = SpatialiteDB.new(tempfile.path)
    result = db.execute("select count(*) || 'ideal arch ent' from idealAEnt union select count(*) || 'ideal reln'  from idealreln union select count(*) || 'aent type' from aenttype union select count(*) || 'relntype' from relntype union select count(*) || 'attributekey'  from attributekey;")
    result[0].should == ['2aent type']
    result[1].should == ['30attributekey']
    result[2].should == ['3ideal reln']
    result[3].should == ['3relntype']
    result[4].should == ['46ideal arch ent']
    tempfile.unlink
  end

  it 'Generates and Parses data_schema.xml with single qoutes' do
    tempfile = Tempfile.new('db.sqlite3')
    Database.generate_database(tempfile.path, Rails.root.join('spec', 'assets', 'pottery.xml').to_s)
    tempfile.unlink
  end

  it 'Generates and Parses data_schema.xml with file and thumbnail attributes' do
    tempfile = Tempfile.new('db.sqlite3')
    Database.generate_database(tempfile.path, Rails.root.join('spec', 'assets', 'data_schema_files.xml').to_s)
    db = SpatialiteDB.new(tempfile.path)
    result = db.execute("select attributename from attributekey where attributeisfile = 1 order by attributename");
    result.map {|row| row.first}.should == ["entity_audio", "entity_file", "entity_image", "entity_video", "rel_audio", "rel_file", "rel_image", "rel_video"]
    result = db.execute("select attributename from attributekey where attributeisfile = 1 and attributeusethumbnail = 1 order by attributename");
    result.map {|row| row.first}.should == ["entity_image", "entity_video", "rel_image", "rel_video"]
    tempfile.unlink
  end

  describe 'Merging databases', :ignore_jenkins => true do
    it 'Empty database and Empty database' do
      p1 = make_project_module('Module 1')
      p2 = make_project_module('Module 2')

      init_database(p1.db.spatialite_db)
      init_database(p2.db.spatialite_db)

      p1.db.merge_database(p2.db.path, 1)

      is_database_empty(p1.db.spatialite_db).should be_true
    end

    it 'Empty database and Full database' do
      version = 1

      p1 = make_project_module('Module 1')
      p2 = make_project_module('Module 2')

      init_database(p1.db.spatialite_db)
      fill_database(p2.db.spatialite_db, version)

      p1.db.merge_database(p2.db.path, version)

      is_database_same(p1.db.spatialite_db, p2.db.spatialite_db).should be_true
    end

    it 'Full database and Empty database' do
      version = 1

      p1 = make_project_module('Module 1')
      p2 = make_project_module('Module 2')

      init_database(p1.db.spatialite_db)
      fill_database(p1.db.spatialite_db, version)

      backup_db1 = backup_database(p1.db.spatialite_db)

      p1.db.merge_database(p2.db.path, version)

      is_database_same(backup_db1, p1.db.spatialite_db).should be_true
    end

    it 'Full database and Full database' do
      version = 1

      p1 = make_project_module('Module 1')
      p2 = make_project_module('Module 2')

      fill_database(p1.db.spatialite_db, version)
      fill_database(p2.db.spatialite_db)

      backup_db1 = backup_database(p1.db.spatialite_db)

      p1.db.merge_database(p2.db.path, version)

      is_database_merged(p1.db.spatialite_db, backup_db1, p2.db.spatialite_db).should be_true
    end

    it 'Does not insert duplicate records' do
      version = 1
      
      p1 = make_project_module('Module 1')
      fill_database(p1.db.spatialite_db, version)
      
      backup_db1 = backup_database(p1.db.spatialite_db)

      p1.db.merge_database(backup_db1.path, version)

      is_database_same(backup_db1, p1.db.spatialite_db).should be_true
    end

    it 'Merge rows must have correct version number' do
      p1 = make_project_module('Module 1')
      p2 = make_project_module('Module 2')
      p3 = make_project_module('Module 3')

      init_database(p1.db.spatialite_db)
      fill_database(p2.db.spatialite_db, nil, 0)
      fill_database(p3.db.spatialite_db, nil, 1000)

      p1.db.merge_database(p2.db.path, 1)
      p1.db.merge_database(p3.db.path, 2)

      is_version_database_same(p1.db.spatialite_db, p2.db.spatialite_db, 1).should be_true
      is_version_database_same(p1.db.spatialite_db, p3.db.spatialite_db, 2).should be_true
    end

  end

end
