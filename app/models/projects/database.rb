require Rails.root.join('lib/spatialite_db')
require Rails.root.join('app/models/projects/web_query')

class Database

  def initialize(project)
    @project = project
    @db = SpatialiteDB.new(@project.get_path(:db))
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

  def get_arch_ent_info(uuid,aenttimestamp)
    info = @db.execute(WebQuery.get_arch_ent_info, uuid, aenttimestamp)
    info
  end

  def get_arch_ent_attribute_info(uuid,valuetimestamp,attribute_id)
    info = @db.execute(WebQuery.get_arch_ent_attribute_info, uuid, valuetimestamp,attribute_id)
    info
  end

  def get_arch_ent_attribute_for_comparison(uuid)
    attributes = @db.execute(WebQuery.get_arch_ent_attribute_for_comparison, uuid)
    attributes
  end

  def update_arch_entity_attribute(uuid, vocab_id, attribute_id, measure, freetext, certainty)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      measure.length.times do |i|
        if vocab_id.blank?
          @db.execute(WebQuery.insert_arch_entity_attribute, uuid, userid, vocab_id, attribute_id, measure[i-1], freetext[i-1], certainty[i-1], currenttime)
        else
          @db.execute(WebQuery.insert_arch_entity_attribute, uuid, userid, vocab_id[i-1], attribute_id, measure[i-1], freetext[i-1], certainty[i-1], currenttime)
        end
      end
      @project.db_mgr.make_dirt
    end
  end

  def insert_updated_arch_entity(uuid, vocab_id, attribute_id, measure, freetext, certainty)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      @db.execute(WebQuery.insert_arch_entity, userid, uuid)
      vocab_id.length.times do |i|
        @db.execute(WebQuery.insert_arch_entity_attribute, uuid, userid, vocab_id[i-1], attribute_id[i-1], measure[i-1], freetext[i-1], certainty[i-1], currenttime)
      end
      @project.db_mgr.make_dirt
    end
  end

  def delete_arch_entity(uuid)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      @db.execute(WebQuery.delete_arch_entity, userid, uuid)
      @project.db_mgr.make_dirt
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
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      freetext.length.times do |i|
        if vocab_id.blank?
          @db.execute(WebQuery.insert_relationship_attribute, relationshipid, userid, attribute_id, vocab_id,  freetext[i-1], certainty[i-1], currenttime)
        else
          @db.execute(WebQuery.insert_relationship_attribute, relationshipid, userid, attribute_id, vocab_id[i-1],  freetext[i-1], certainty[i-1], currenttime)
        end
      end
      @project.db_mgr.make_dirt
    end
  end

  def insert_updated_rel(relationshipid, vocab_id, attribute_id, freetext, certainty)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      @db.execute(WebQuery.insert_relationship, userid, relationshipid)
      vocab_id.length.times do |i|
        @db.execute(WebQuery.insert_relationship_attribute, relationshipid, userid, attribute_id[i-1], vocab_id[i-1],  freetext[i-1], certainty[i-1], currenttime)
      end
      @project.db_mgr.make_dirt
    end
  end

  def delete_relationship(relationshipid)
    @project.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      @db.execute(WebQuery.delete_relationship, userid, relationshipid)
      @project.db_mgr.make_dirt
    end
  end

  def get_rel_info(relid,relntimestamp)
    info = @db.execute(WebQuery.get_rel_info, relid, relntimestamp)
    info
  end

  def get_rel_attribute_info(relid,valuetimestamp,attribute_id)
    info = @db.execute(WebQuery.get_rel_attribute_info, relid, valuetimestamp,attribute_id)
    info
  end

  def get_rel_attribute_for_comparison(relid)
    attributes = @db.execute(WebQuery.get_rel_attribute_for_comparison, relid)
    attributes
  end

  def get_rel_arch_ent_members(relationshipid, limit, offset)
    uuids = @db.execute(WebQuery.get_arch_entities_in_relationship, relationshipid, limit, offset)
    uuids
  end

  def get_non_member_arch_ent(relationshipid, query, limit, offset)
    uuids = @db.execute(WebQuery.get_arch_entities_not_in_relationship, query, query, query, limit, offset,relationshipid)
    uuids
  end

  def get_verbs_for_relation(relntypeid)
    verbs = @db.execute(WebQuery.get_verbs_for_relationship, relntypeid, relntypeid)
    verbs
  end

  def add_arch_ent_member(relationshipid, uuid, verb)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.insert_arch_entity_relationship, uuid, relationshipid, userid, verb)
      @project.db_mgr.make_dirt
    end
  end

  def delete_arch_ent_member(relationshipid, uuid)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.delete_arch_entity_relationship, uuid, relationshipid, userid)
      @project.make_dirt
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
    version = @db.execute(WebQuery.get_current_version)
    return version.first.first.to_s if version and version.first
    '0'
  end

  def latest_version
    version = @db.execute(WebQuery.get_latest_version)
    return version.first.first.to_s if version and version.first
    '0'
  end

  def add_version(userid)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.insert_user_version, current_timestamp, userid)
      @project.db_mgr.make_dirt
      latest_version
    end
  end

  def merge_database(fromDB, version)
    @project.db_mgr.with_lock do
      @db.execute_batch(WebQuery.merge_database(fromDB, version))

      @project.db_mgr.make_dirt
    end
  end

  def create_app_database(toDB)
    #@project.with_lock do

      db = SpatialiteDB.new(toDB)
      db.execute('select initspatialmetadata();')
      
      @db.execute_batch(WebQuery.create_app_database(toDB))

    #end
  end

  def create_app_database_from_version(toDB, version)
    #@project.with_lock do

      db = SpatialiteDB.new(toDB)
      db.execute('select initspatialmetadata();')
      
      @db.execute_batch(WebQuery.create_app_database_from_version(toDB, version))

    #end
  end

  # static
  def self.generate_database(file, xml)
    db = SpatialiteDB.new(file)
    content = File.read(Rails.root.join('lib', 'assets', 'init.sql'))
    db.execute_batch(content)
    data_definition = XSLTParser.parse_data_schema(xml)
    db.execute_batch(data_definition)
    gps_definition = XSLTParser.parse_data_schema(Rails.root.join('lib/assets/gps_schema.xml'))
    db.execute_batch(gps_definition)
  end

  # Testing
  def spatialite_db
    @db
  end

  def spatialite_db=(value)
    @db = value
  end

  def project
    @project
  end

  def path
    @db.path
  end

  private

  def current_timestamp
    Time.now.getgm.strftime('%Y-%m-%d %H:%M:%S')
  end

  def userid
    0
  end

end