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
    expected = [[1000011365058823906,"34768",37008,"location","Loc B",nil,nil,0.37,"dropdown"],
                [1000011365058823906,"34768",37392,"location","Loc C",nil,nil,0.28,"dropdown"],
                [1000011365058823906,"17136",nil,"name",nil,nil,"Indigo",0.72,"string"],
                [1000011365058823906,"38416",40272,"picture","cugl69808.jpg",nil,"",0.83,"dropdown"],
                [1000011365058823906,"53296",nil,"supervisor",nil,nil,"superc",0.55,"radiogroup"],
                [1000011365058823906,"29344",nil,"timestamp",nil,nil,"2013-04-04 17:59:58",0.99,"timestamp"],
                [1000011365058823906,"31072",33744,"type","Type C",nil,"",0.72,"checklist"],
                [1000011365058823906,"27616",nil,"value",nil,17597,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,26099,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,151826,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,170587,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,200269,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,324373,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,339043,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,345945,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,399373,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,401755,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,459104,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,476048,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,612170,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,690870,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,756435,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,794183,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,814526,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,854547,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,893327,nil,1.0,"integer"],
                [1000011365058823906,"27616",nil,"value",nil,969578,nil,1.0,"integer"]]
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
    expected = [[1000011365058823908,37008,"34768","location",nil,1.0,"Loc B",21904,"dropdown"],
                [1000011365058823908,37392,"34768","location",nil,1.0,"Loc C",21904,"dropdown"],
                [1000011365058823908,37776,"34768","location",nil,1.0,"Loc D",21904,"dropdown"],
                [1000011365058823908,nil,"17136","name","Jellyfish",1.0,nil,21904,"string"],
                [1000011365058823908,nil,"29344","timestamp","2013-04-30 02:31:46",1.0,nil,21904,"timestamp"]]
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

  it 'Load all arch entities with multi-value attributes' do
    expected = [[1000011365058835006,"Simple","location","Loc A, Loc B, Loc C",37392,"34768","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","name","Ballsun-Stanton, Brian",nil,"17136","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","timestamp","2013-04-04 17:59:58",nil,"29344","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","value","743895, 965129, 662605, 133500, 835655, 809098, 918434, 121551, 303306, 862096, 810461, 427823, 610287, 412728, 146620, 747748, 17115, 548408, 235159, 736398",nil,"27616","2013-05-09 02:39:18",nil]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.load_all_arch_entities, '1', '0')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Load all relationships with multi-value attributes' do
    expected = [[1000011365058823908,"Similar","location","Loc B, Loc C, Loc D",37776,"34768","2013-05-06 07:26:20"],
                [1000011365058823908,"Similar","name","Jellyfish",nil,"17136","2013-05-06 07:26:20"],
                [1000011365058823908,"Similar","timestamp","2013-04-30 02:31:46",nil,"29344","2013-05-06 07:26:20"]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.load_all_relationships, '1', '0')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Load typed arch entitites with multi-value attributes' do
    expected = [[1000011365058835006,"Simple","location","Loc A, Loc B, Loc C",37392,"34768","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","name","Ballsun-Stanton, Brian",nil,"17136","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","timestamp","2013-04-04 17:59:58",nil,"29344","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","value","743895, 965129, 662605, 133500, 835655, 809098, 918434, 121551, 303306, 862096, 810461, 427823, 610287, 412728, 146620, 747748, 17115, 548408, 235159, 736398",nil,"27616","2013-05-09 02:39:18",nil]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.load_arch_entities, '24960', '1', '0')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Load typed relationships with multi-value attributes' do
    expected = [[1000011365058823908,"Similar","location","Loc B, Loc C, Loc D",37776,"34768","2013-05-06 07:26:20"],
                [1000011365058823908,"Similar","name","Jellyfish",nil,"17136","2013-05-06 07:26:20"],
                [1000011365058823908,"Similar","timestamp","2013-04-30 02:31:46",nil,"29344","2013-05-06 07:26:20"]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.load_relationships, '21904', '1', '0')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Search arch entities with multi-value attributes' do
    expected = [[1000011365058835006,"Simple","location","Loc A, Loc B, Loc C",37392,"34768","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","name","Ballsun-Stanton, Brian",nil,"17136","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","timestamp","2013-04-04 17:59:58",nil,"29344","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","value","743895, 965129, 662605, 133500, 835655, 809098, 918434, 121551, 303306, 862096, 810461, 427823, 610287, 412728, 146620, 747748, 17115, 548408, 235159, 736398",nil,"27616","2013-05-09 02:39:18",nil]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.search_arch_entity, 'all','all','all','1','0')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Search relationships with multi-value attributes' do
    expected = [[1000011365058823908,"location","Loc B, Loc C, Loc D","Loc D"],
                [1000011365058823908,"name","Jellyfish",nil],
                [1000011365058823908,"timestamp","2013-04-30 02:31:46",nil]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.search_relationship, 'jelly','jelly','1','0')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Search arch entities in relationship with multi-value attributes' do
    expected = [[1000011365058824906,"Simple","location","Loc B",37008,"34768","2013-05-06 04:12:15",nil],
                [1000011365058824906,"Simple","name","George",nil,"17136","2013-05-06 04:12:15",nil],
                [1000011365058824906,"Simple","timestamp","2013-04-04 17:59:58",nil,"29344","2013-05-06 04:12:15",nil],
                [1000011365058824906,"Simple","value","192085, 299389, 459881, 870754, 552986, 51695, 36604, 797887, 895371, 989115, 122847, 879369, 407630, 917785, 84160, 868460, 852297, 953002, 908303, 376222",nil,"27616","2013-05-06 04:12:15",nil],
                [1000011365058825006,"Simple","location","Loc B, Loc D",37776,"34768","2013-05-06 04:12:15",nil],
                [1000011365058825006,"Simple","name","Charles",nil,"17136","2013-05-06 04:12:15",nil],
                [1000011365058825006,"Simple","timestamp","2013-04-04 17:59:58",nil,"29344","2013-05-06 04:12:15",nil],
                [1000011365058825006,"Simple","value","78730, 751081, 348180, 288063, 911309, 799634, 796203, 241568, 464467, 985003, 164923, 331021, 828669, 752685, 586776, 906705, 182690, 136131, 573983, 855194",nil,"27616","2013-05-06 04:12:15",nil]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.get_arch_entities_in_relationship, '1000011365058824909','2','0')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end

  it 'Search arch entities not in relationship with multi-value attributes' do
    expected = [[1000011365058835006,"Simple","location","Loc A, Loc B, Loc C",37392,"34768","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","name","Ballsun-Stanton, Brian",nil,"17136","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","timestamp","2013-04-04 17:59:58",nil,"29344","2013-05-09 02:39:18",nil],
                [1000011365058835006,"Simple","value","743895, 965129, 662605, 133500, 835655, 809098, 918434, 121551, 303306, 862096, 810461, 427823, 610287, 412728, 146620, 747748, 17115, 548408, 235159, 736398",nil,"27616","2013-05-09 02:39:18",nil]]
    begin
      temp_file = Tempfile.new('db')
      FileUtils.cp(test_multivalued_db, temp_file.path)
      db = SpatialiteDB.new(temp_file.path)
      results = db.execute(WebQuery.get_arch_entities_not_in_relationship, 'all','all','all','1','0','1000011365058824909')
    rescue Exception => e
      raise e
    ensure
      temp_file.unlink if temp_file
    end
    results.should =~ expected
  end
end