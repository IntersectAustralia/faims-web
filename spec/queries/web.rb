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


end