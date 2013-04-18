class Database
  require Rails.root.join('lib/spatialite_db')

  def initialize(project)
    @project = project
    @db = SpatialiteDB.new(@project.db_path)
  end

  def load_arch_entity(type, limit, offset)
    uuids = type.eql?('all') ?
      @db.execute(WebQuery.load_all_arch_entities, limit, offset) : @db.execute(WebQuery.load_arch_entities, type, limit, offset)
    uuids
  end

  def search_arch_entity(limit, offset, query)
    uuids = @db.execute(WebQuery.search_arch_entity, query, query, query, limit, offset)
    uuids
  end

  def get_arch_entity_attributes(uuid)
    attributes = @db.execute(WebQuery.get_arch_entity_attributes, uuid)
    attributes
  end

  def update_arch_entity_attribute(uuid, vocab_id, attribute_id, measure, freetext, certainty)
    @project.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      @db.execute(WebQuery.insert_arch_entity_attribute, uuid, vocab_id, attribute_id, measure, freetext, certainty, current_timestamp)
    end
  end

  def delete_arch_entity(uuid)
    @project.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      @db.execute(WebQuery.delete_arch_entity, current_timestamp, uuid)
    end
  end

  def load_rel(type, limit, offset)
    relationshipids = type.eql?('all') ?
      @db.execute(WebQuery.load_all_relationships, limit, offset) : @db.execute(WebQuery.load_relationships, type, limit, offset)
    relationshipids
  end

  def search_rel(limit, offset, query)
    relationshipids = @db.execute(WebQuery.search_relationship, query, query, limit, offset)
    relationshipids
  end

  def get_rel_attributes(relationshipid)
    attributes = @db.execute(WebQuery.get_relationship_attributes, relationshipid)
    attributes
  end

  def update_rel_attribute(relationshipid, vocab_id, attribute_id, freetext, certainty)
    @project.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      @db.execute(WebQuery.insert_relationship_attribute, relationshipid, attribute_id, vocab_id, freetext, certainty, current_timestamp)
    end
  end

  def delete_relationship(relationshipid)
    @project.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      @db.execute(WebQuery.delete_relationship, current_timestamp, relationshipid)
    end
  end

  def get_rel_arch_ent_members(relationshipid, limit, offset)
    uuids = @db.execute(WebQuery.get_arch_entities_in_relationship, relationshipid, limit, offset)
    uuids
  end

  def get_non_member_arch_ent(relationshipid, query, limit, offset)
    uuids = @db.execute(WebQuery.get_arch_entites_not_in_relationship, query, query, query, relationshipid, limit, offset)
    uuids
  end

  def get_verbs_for_relation(relntypeid)
    verbs = @db.execute(WebQuery.get_verbs_for_relationship, relntypeid, relntypeid)
    verbs
  end

  def add_arch_ent_member(relationshipid, uuid, verb)
    @project.with_lock do
      @db.execute(WebQuery.insert_arch_entity_relationship, uuid, relationshipid, verb)
    end
  end

  def delete_arch_ent_member(relationshipid, uuid)
    @project.with_lock do
      @db.execute(WebQuery.delete_arch_entity_relationship, uuid, relationshipid)
    end
  end

  def get_vocab(attributeid)
    vocabs = @db.execute(WebQuery.get_vocab, attributeid)
    vocabs
  end

  def get_arch_ent_types
    types = @db.execute(WebQuery.get_arch_entity_types)
    types
  end

  def get_rel_types
    types = @db.execute(WebQuery.get_relationship_types)
    types
  end

  def current_version
    version = @db.execute(WebQuery.get_current_version).first
    return version.first if version
    version
  end

  def add_version(userid)
    @project.with_lock do
      @db.execute(WebQuery.insert_user_version, current_timestamp, userid)
      version = @db.execute(WebQuery.get_current_version).first
      return version.first if version
    end
  end

  def self.generate_database(file, xml)
    db = SpatialiteDB.new(file)
    db.execute('select initspatialmetadata()')
    content = File.read(Rails.root.join('lib', 'assets', 'init.sql'))
    db.execute_batch(content)
    data_definition = XSLTParser.parse_data_schema(xml)
    db.execute_batch(data_definition)
  end

  def self.merge_database(project_key, toDB, fromDB, version)
    Project.try_lock_project(project_key)

    db = SpatialiteDB.new(toDB)
    db.execute_batch(WebQuery.merge_database(fromDB, version))

    Project.unlock_project(project_key)
  end

  def self.create_app_database(project_key, fromDB, toDB)
    Project.try_lock_project(project_key)

    db = SpatialiteDB.new(toDB)
    db.execute('select initspatialmetadata()')

    db = SpatialiteDB.new(fromDB)
    db.execute_batch(WebQuery.create_app_database(toDB))

    Project.unlock_project(project_key)
  end

  def self.create_app_database_from_version(project_key, fromDB, toDB, version)
    Project.try_lock_project(project_key)

    db = SpatialiteDB.new(toDB)
    db.execute('select initspatialmetadata()')

    db = SpatialiteDB.new(fromDB)
    db.execute_batch(WebQuery.create_app_database_from_version(toDB, version))

    Project.unlock_project(project_key)
  end

  private

  def current_timestamp
    Time.now.getgm.strftime('%Y-%m-%d %H:%M:%S')
  end

end