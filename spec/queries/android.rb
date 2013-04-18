require 'spec_helper'
require Rails.root.join('spec/queries/query_helper')

describe 'Android Database Queries' do

  it 'Insert Arch Entity' do
    lambda {
      result = run_query(AndroidQuery.insert_arch_entity, generate_uuid, generate_user_id, random_geo_data, timestamp)
      result
    }.should_not raise_error
  end

  it 'Insert Arch Entity Attribute' do
    lambda {
      result = run_query(AndroidQuery.insert_arch_entity_attribute, generate_uuid, random_vocab_id, random_measure, random_free_text, random_certainty, timestamp, random_attribute)
      result
    }.should_not raise_error
  end

  it 'Insert Relationship' do
    lambda {
      result = run_query(AndroidQuery.insert_relationship, generate_relationship_id, random_geo_data, timestamp)
      result
    }.should_not raise_error
  end

  it 'Insert Relationship Attribute' do
    lambda {
      result = run_query(AndroidQuery.insert_relationship_attribute, generate_relationship_id, random_vocab_id, random_free_text, random_certainty, timestamp, random_attribute)
      result
    }.should_not raise_error
  end

  it 'Has Arch Entity Attribute' do
    lambda {
      result = run_query(AndroidQuery.has_arch_entity_attribute, random_entity_type, random_attribute)
      result
    }.should_not raise_error
  end

  it 'Has Relationship Attribute' do
    lambda {
      result = run_query(AndroidQuery.has_relationship_attribute, random_relationship_type, random_attribute)
      result
    }.should_not raise_error
  end

  it 'Insert Arch Entity Relationship' do
    lambda {
      result = run_query(AndroidQuery.insert_arch_entity_relationship, generate_uuid, generate_relationship_id, random_verb, timestamp)
      result
    }.should_not raise_error
  end

  it 'Fetch Arch Entity' do
    lambda {
      result = run_query(AndroidQuery.fetch_arch_entity, random_uuid)
      result
    }.should_not raise_error
  end

  it 'Fetch Arch Entity Geometry' do
    lambda {
      result = run_query(AndroidQuery.fetch_arch_entity_geometry, random_uuid)
      result
    }.should_not raise_error
  end

  it 'Fetch Relationship' do
    lambda {
      result = run_query(AndroidQuery.fetch_relationship, random_relationship_id)
      result
    }.should_not raise_error
  end

  it 'Fetch Relationship Geometry' do
    lambda {
      result = run_query(AndroidQuery.fetch_relationship_geometry, random_relationship_id)
      result
    }.should_not raise_error
  end

  it 'Has Arch Entity Type' do
    lambda {
      result = run_query(AndroidQuery.has_arch_entity_type, random_entity_type)
      result
    }.should_not raise_error
  end

  it 'Has Arch Entity' do
    lambda {
      result = run_query(AndroidQuery.has_arch_entity, random_uuid)
      result
    }.should_not raise_error
  end

  it 'Has Relationship Type' do
    lambda {
      result = run_query(AndroidQuery.has_relationship_type, random_relationship_type)
      result
    }.should_not raise_error
  end

  it 'Has Relationship' do
    lambda {
      result = run_query(AndroidQuery.has_relationship, random_relationship_id)
      result
    }.should_not raise_error
  end

end