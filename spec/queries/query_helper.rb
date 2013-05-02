def test_db
  Rails.root.join('spec/assets/test_db.sqlite3').to_s
end

def test_multivalued_db
  Rails.root.join('spec/assets/multivalue.sqlite3').to_s
end

def run_query(query, *args)
  begin
    temp_file = Tempfile.new('db')
    FileUtils.cp(test_db, temp_file.path)
    db = SpatialiteDB.new(temp_file.path)
    db.execute(query, args)
  rescue Exception => e
      raise e
  ensure
    temp_file.unlink if temp_file
  end
end

def run_batch_query(query, *args)
  begin
    db = SpatialiteDB.new(test_db)
    db.execute_batch(query, args)
  rescue Exception => e
    raise e
  end
end

def generate_uuid
  SecureRandom.uuid
end

def generate_relationship_id
  SecureRandom.uuid
end

def generate_user_id
  SecureRandom.uuid
end

def random_user_id
  0 # TODO
end

def random_geo_data
  nil # TODO
end

def random_measure
  1.0 # TODO
end

def random_free_text
  'This is random.' # TODO
end

def random_certainty
  1.0 # TODO
end

def random_attribute
  nil # TODO
end

def random_attribute_id
  0 # TODO
end

def random_vocab_id
  0 # TODO
end

def random_entity_type
  nil # TODO
end

def random_entity_type_id
  0 # TODO
end

def random_relationship_type
  nil # TODO
end

def random_relationship_type_id
  0 # TODO
end

def random_verb
  'Verb' # TODO
end

def random_uuid
  0 # TODO
end

def random_relationship_id
  0 # TODO
end

def random_attribute_id_with_vocab
  0 # TODO
end

def timestamp
  Time.now.getgm.strftime('%Y-%m-%d %H:%M:%S')
end