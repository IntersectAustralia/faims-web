require 'spec_helper'
require Rails.root.join('spec/queries/query_helper')

describe 'Web Database Queries' do

  before(:each) do
    @limit = 10
    @offset = 0
  end

  it 'Load Arch Entities' do
    lambda {
      result = run_query(WebQuery.load_arch_entities, random_entity_type_id, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Load All Arch Entities' do
    lambda {
      result = run_query(WebQuery.load_all_arch_entities, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Search Entities' do
    lambda {
      query = nil
      result = run_query(WebQuery.search_arch_entity, query, query, query, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Get Arch Entity Attributes' do
    lambda {
      result = run_query(WebQuery.get_arch_entity_attributes, random_uuid)
      result
    }.should_not raise_error
  end

  it 'Insert Version' do
    lambda {
      result = run_query(WebQuery.insert_version, timestamp)
      result
    }.should_not raise_error
  end

  it 'Insert Arch Entity Attribute' do
    lambda {
      result = run_query(WebQuery.insert_arch_entity_attribute, random_uuid, random_vocab_id, random_attribute_id, random_measure, random_free_text, random_certainty, timestamp)
      result
    }.should_not raise_error
  end

  it 'Delete Arch Entity' do
    lambda {
      result = run_query(WebQuery.delete_arch_entity, timestamp, random_uuid)
      result
    }.should_not raise_error
  end

  it 'Load Relationships' do
    lambda {
      result = run_query(WebQuery.load_relationships, random_relationship_type_id, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Load All Relationships' do
    lambda {
      result = run_query(WebQuery.load_relationships, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Search Relationships' do
    lambda {
      query = nil
      result = run_query(WebQuery.search_relationship, query, query, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Get Relationship Attributes' do
    lambda {
      result = run_query(WebQuery.get_relationship_attributes, random_relationship_id)
      result
    }.should_not raise_error
  end

  it 'Insert Relationship Attribute' do
    lambda {
      result = run_query(WebQuery.insert_relationship_attribute, random_relationship_id, random_attribute_id, random_vocab_id, random_free_text, random_certainty, timestamp)
      result
    }.should_not raise_error
  end

  it 'Delete Relationship Attribute' do
    lambda {
      result = run_query(WebQuery.delete_relationship, timestamp, random_relationship_id)
      result
    }.should_not raise_error
  end

  it 'Get Entities in Relationship' do
    lambda {
      result = run_query(WebQuery.get_arch_entities_in_relationship, random_relationship_id, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Get Entities not in Relationship' do
    lambda {
      query = nil
      result = run_query(WebQuery.get_arch_entities_not_in_relationship, query, query, query, random_relationship_id, @limit, @offset)
      result
    }.should_not raise_error
  end

  it 'Get Verbs for Relationship' do
    lambda {
      reltype_id = random_relationship_type_id
      result = run_query(WebQuery.get_verbs_for_relationship, reltype_id, reltype_id)
      result
    }.should_not raise_error
  end

  it 'Insert Arch Entity Relationship' do
    lambda {
      result = run_query(WebQuery.insert_arch_entity_relationship, random_uuid, random_relationship_id, random_verb)
      result
    }.should_not raise_error
  end

  it 'Delete Arch Entity Relationship' do
    lambda {
      result = run_query(WebQuery.delete_arch_entity_relationship, random_uuid, random_relationship_id)
      result
    }.should_not raise_error
  end

  it 'Get Vocab' do
    lambda {
      result = run_query(WebQuery.get_vocab, random_attribute_id_with_vocab)
      result
    }.should_not raise_error
  end

  it 'Get Arch Entity Types' do
    lambda {
      result = run_query(WebQuery.get_arch_entity_types)
      result
    }.should_not raise_error
  end

  it 'Get Relationship Types' do
    lambda {
      result = run_query(WebQuery.get_relationship_types)
      result
    }.should_not raise_error
  end

  it 'Get Current Verison' do
    lambda {
      result = run_query(WebQuery.get_current_version)
      result
    }.should_not raise_error
  end

  it 'Insert User Version' do
    lambda {
      result = run_query(WebQuery.insert_user_version, timestamp, random_user_id)
      result
    }.should_not raise_error
  end

  it 'Merge database' do
    lambda {
      begin
        temp_file = Tempfile.new('db')
        version = nil
        fromDB = test_db
        toDB = temp_file.path
        db = SpatialiteDB.new(toDB)
        db.execute_batch(WebQuery.merge_database(fromDB, version))
      rescue Exception => e
        raise e
      ensure
        temp_file.unlink if temp_file
      end
    }.should_not raise_error
  end

  it 'Create App Database' do
    lambda {
      begin
        temp_file = Tempfile.new('db')
        fromDB = test_db
        toDB = temp_file.path
        db = SpatialiteDB.new(toDB)
        db.execute('select initspatialmetadata()')

        db = SpatialiteDB.new(fromDB)
        db.execute_batch(WebQuery.create_app_database(toDB))
      rescue Exception => e
        raise e
      ensure
        temp_file.unlink if temp_file
      end
    }.should_not raise_error
  end

  it 'Create App Database from Version' do
    lambda {
      begin
        temp_file = Tempfile.new('db')
        version = nil
        fromDB = test_db
        toDB = temp_file.path
        db = SpatialiteDB.new(toDB)
        db.execute('select initspatialmetadata()')

        db = SpatialiteDB.new(fromDB)
        db.execute_batch(WebQuery.create_app_database_from_version(toDB, version))
      rescue Exception => e
        raise e
      ensure
        temp_file.unlink if temp_file
      end
    }.should_not raise_error
  end

  it 'Get multi-valued arch ent attributes' do
    expected = [[1000011365058823906, "34768", 37392, "location", "Loc C", nil, "foo", 0.46, "dropdown"],
                [1000011365058823906, "34768", 37776, "location", "Loc D", nil, "foo", 0.46, "dropdown"],
                [1000011365058823906, "17136", nil, "name", nil, nil, "Brian", nil, "string"],
                [1000011365058823906, "38416", 40272, "picture", "cugl69808.jpg", nil, "", 1.0, "dropdown"],
                [1000011365058823906, "53296", nil, "supervisor", nil, nil, "superc", 1.0, "radiogroup"],
                [1000011365058823906, "29344", nil, "timestamp", nil, nil, "2013-04-04 17:59:58", nil, "timestamp"],
                [1000011365058823906, "31072", 33744, "type", "Type C", nil, "", 1.0, "checklist"]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.get_arch_entity_attributes, '1000011365058823906')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Get multi-valued arch ent attributes' do
    expected = [[1000011365058823908, 37392, "34768", "location", nil, 1.0, "Loc C", 21904, "dropdown"],
                [1000011365058823908, 37776, "34768", "location", nil, 1.0, "Loc D", 21904, "dropdown"],
                [1000011365058823908, nil, "17136", "name", "Bar!", 1.0, nil, 21904, "string"],
                [1000011365058823908, nil, "29344", "timestamp", "2013-4-30", 1.0, nil, 21904, "timestamp"]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.get_relationship_attributes, '1000011365058823908')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

end