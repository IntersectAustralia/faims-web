require Rails.root.join('lib/spatialite_db')
require Rails.root.join('app/models/projects/web_query')

class Database

  def initialize(project)
    @project = project
    @db = SpatialiteDB.new(@project.get_path(:db))
  end

  def is_arch_entity_dirty(uuid)
    result = @db.execute(WebQuery.is_arch_entity_dirty, uuid, uuid)
    return result.first.first > 0 if result and result.first and result.first.first
    nil
  end

  def is_relationship_dirty(relationshipid)
    result = @db.execute(WebQuery.is_relationship_dirty, relationshipid)
    return result.first.first > 0 if result and result.first and result.first.first
    nil
  end

  def get_arch_entity_type(uuid)
    type = @db.execute(WebQuery.get_arch_entity_type, uuid)
    return type.first.first if type and type.first
    nil
  end

  def get_relationship_type(relationshipid)
    type = @db.execute(WebQuery.get_relationship_type, relationshipid)
    return type.first.first if type and type.first
    nil
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

  def update_arch_entity_attribute(uuid, vocab_id, attribute_id, measure, freetext, certainty, ignore_errors = nil)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      measure.length.times do |i|
        if vocab_id.blank?
          @db.execute(WebQuery.insert_arch_entity_attribute, uuid, userid, vocab_id, attribute_id, measure[i-1], freetext[i-1], certainty[i-1], currenttime)
        else
          @db.execute(WebQuery.insert_arch_entity_attribute, uuid, userid, vocab_id[i-1], attribute_id, measure[i-1], freetext[i-1], certainty[i-1], currenttime)
        end

        validate_aent_value(uuid, currenttime, attribute_id) unless ignore_errors
      end
      @project.db_mgr.make_dirt
    end
  end

  def update_aent_value_as_dirty(uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum, isdirty, isdirtyreason)
    @db.execute(WebQuery.update_aent_value_as_dirty, isdirty, isdirtyreason, uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum)
  end

  def insert_updated_arch_entity(uuid, vocab_id, attribute_id, measure, freetext, certainty)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      @db.execute(WebQuery.insert_arch_entity, userid, uuid,currenttime)
      vocab_id.length.times do |i|
        @db.execute(WebQuery.insert_arch_entity_attribute, uuid, userid, vocab_id[i-1], attribute_id[i-1], measure[i-1], freetext[i-1], certainty[i-1], currenttime)
      end
      
      validate_aent_value(uuid, currenttime, attribute_id)
      @project.db_mgr.make_dirt
    end
  end

  def get_arch_ent_history(uuid)
    timestamps = @db.execute(WebQuery.get_arch_ent_history, uuid, uuid)
    timestamps
  end

  def get_arch_ent_attributes_at_timestamp(uuid, timestamp)
    attributes =  @db.execute(WebQuery.get_arch_ent_attributes_at_timestamp, @project.get_settings['srid'], @uuid, timestamp, uuid, timestamp)
    attributes
  end

  def get_arch_ent_attributes_changes_at_timestamp(uuid, timestamp)
    srid = @project.get_settings['srid']
    changes = @db.execute(WebQuery.get_arch_ent_attributes_changes_at_timestamp, uuid, timestamp, uuid, timestamp, srid,
                          uuid, timestamp, srid, uuid, timestamp, uuid, timestamp, uuid, timestamp, uuid, timestamp, uuid, timestamp)
    changes
  end

  def revert_arch_ent_to_timestamp(uuid, timestamp)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      @db.execute(WebQuery.insert_arch_ent_at_timestamp, userid, currenttime, uuid, timestamp)
      @db.execute(WebQuery.insert_arch_ent_attributes_at_timestamp, userid,currenttime, uuid, timestamp)
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

  def update_rel_attribute(relationshipid, vocab_id, attribute_id, freetext, certainty, ignore_errors = nil)
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

      validate_reln_value(relationshipid, currenttime, attribute_id) unless ignore_errors

      @project.db_mgr.make_dirt
    end
  end

  def update_reln_value_as_dirty(relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum, isdirty, isdirtyreason)
    @db.execute(WebQuery.update_reln_value_as_dirty, isdirty, isdirtyreason, relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum)
  end

  def insert_updated_rel(relationshipid, vocab_id, attribute_id, freetext, certainty)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      @db.execute(WebQuery.insert_relationship, userid, relationshipid)
      vocab_id.length.times do |i|
        @db.execute(WebQuery.insert_relationship_attribute, relationshipid, userid, attribute_id[i-1], vocab_id[i-1],  freetext[i-1], certainty[i-1], currenttime)
      end
      
      validate_reln_value(relationshipid, currenttime, attribute_id)
      @project.db_mgr.make_dirt
    end
  end

  def get_rel_history(relid)
    timestamps = @db.execute(WebQuery.get_rel_history, relid, relid)
    timestamps
  end

  def get_rel_attributes_at_timestamp(relid, timestamp)
    attributes =  @db.execute(WebQuery.get_rel_attributes_at_timestamp, @project.get_settings['srid'], relid, timestamp, relid, timestamp)
    attributes
  end

  def get_rel_attributes_changes_at_timestamp(relid, timestamp)
    srid = @project.get_settings['srid']
    changes = @db.execute(WebQuery.get_rel_attributes_changes_at_timestamp, relid, timestamp, relid, timestamp, srid,
                          relid, timestamp, srid, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp)
    changes
  end

  def revert_rel_to_timestamp(relid, timestamp)
    @project.db_mgr.with_lock do
      currenttime = current_timestamp
      @db.execute(WebQuery.insert_version, currenttime)
      @db.execute(WebQuery.insert_rel_at_timestamp, userid, currenttime, relid, timestamp)
      @db.execute(WebQuery.insert_rel_attributes_at_timestamp, userid,currenttime, relid, timestamp)
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

      validate_records
      @project.db_mgr.make_dirt
    end
  end

  def get_attributes_containing_vocab
    attributes = @db.execute(WebQuery.get_attributes_containing_vocab)
    attributes
  end

  def get_vocabs_for_attribute(attribute_id)
    vocabs = @db.execute(WebQuery.get_vocabs_for_attribute, attribute_id)
    vocabs
  end

  def update_attributes_vocab(attribute_id, vocab_id, vocab_name)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      vocab_id.length.times do |i|
        vocab_id[i-1] = vocab_id[i-1].blank? ? nil : vocab_id[i-1]
        if !vocab_name[i-1].blank?
          @db.execute_batch(WebQuery.update_attributes_vocab,vocab_id[i-1],attribute_id,vocab_name[i-1])
        end
      end
      @project.db_mgr.make_dirt
    end
  end

  def create_app_database(toDB)
    #@project.with_lock do
    fromDB = @project.get_path(:db)
    FileUtils.cp(fromDB,toDB)
    #end
  end

  def create_app_database_from_version(toDB, version)
    #@project.with_lock do

      db = SpatialiteDB.new(toDB)
      db.execute('select initspatialmetadata();')
      
      @db.execute_batch(WebQuery.create_app_database_from_version(toDB, version))

    #end
  end

  def validate_reln_value(relationshipid, relnvaluetimestamp, attributeid)
    return unless File.exists? @project.get_path(:validation_schema)
    begin
      db_validator = DatabaseValidator.new(self, @project.get_path(:validation_schema))

      result = @db.execute(WebQuery.get_reln_value, relationshipid, relnvaluetimestamp, attributeid)
      result.each do |row|
        begin 
          relationshipid = row[0]
          attributeid = row[1]
          attributename = row[2]
          vocabid = row[3]
          fields = {}
          fields['vocab'] = row[4]
          fields['freetext'] = row[5]
          fields['certainty'] = row[6]
          relnvaluetimestamp = row[7]
          userid = row[8]
          versionnum = row[9]

          result = db_validator.validate_reln_value(relationshipid, relnvaluetimestamp, attributename, fields)
          if result
            update_reln_value_as_dirty(relationshipid, relnvaluetimestamp, userid, attributeid, vocabid, fields['freetext'], fields['certainty'], versionnum, 1, result)
          end
        rescue Exception => e
          puts e.to_s
          puts e.backtrace
        end
      end
    rescue Exception => e
      puts e.to_s
      puts e.backtrace
    end
  end

  def validate_aent_value(uuid, valuetimestamp, attributeid)
    return unless File.exists? @project.get_path(:validation_schema)
    begin
      db_validator = DatabaseValidator.new(self, @project.get_path(:validation_schema))

      result = @db.execute(WebQuery.get_aent_value, uuid, valuetimestamp, attributeid)
      result.each do |row|
        begin 
          uuid = row[0]
          attributeid = row[1]
          attributename = row[2]
          vocabid = row[3]
          fields = {}
          fields['vocab'] = row[4]
          fields['measure'] = row[5]
          fields['freetext'] = row[6]
          fields['certainty'] = row[7]
          valuetimestamp = row[8]
          userid = row[9]
          versionnum = row[10]

          result = db_validator.validate_aent_value(uuid, valuetimestamp, attributename, fields)
          if result
            update_aent_value_as_dirty(uuid, valuetimestamp, userid, attributeid, vocabid, fields['measure'], fields['freetext'], fields['certainty'], versionnum, 1, result)
          end
        rescue Exception => e
          puts e.to_s
          puts e.backtrace
        end
      end
    rescue Exception => e
      puts e.to_s
      puts e.backtrace
    end
  end

  # note: assume database already locked
  def validate_records(version = nil)
    version ||= current_version
    result = @db.execute(WebQuery.get_all_aent_values_for_version, version)
    result.each do |row|
      validate_aent_value(row[0], row[1], row[2])
    end
    result = @db.execute(WebQuery.get_all_reln_values_for_version, version)
    result.each do |row|
      validate_reln_value(row[0], row[1], row[2])
    end
    nil
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

  def self.get_spatial_ref_list
    begin
      temp = Tempfile.new('db')
      db = SpatialiteDB.new(temp.path)
      db.execute('select initspatialmetadata()')
      result = db.execute("select upper(auth_name) || ':' || srid || ' - ' || ref_sys_name, auth_srid from spatial_ref_sys;")
    ensure
      temp.unlink if temp
    end
  end

  private

  def current_timestamp
    Time.now.getgm.strftime('%Y-%m-%d %H:%M:%S')
  end

  def userid
    0
  end

end