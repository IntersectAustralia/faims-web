require Rails.root.join('lib/spatialite_db')
require Rails.root.join('app/models/projects/web_query')

class Database

  def initialize(project)
    @project = project
    @db = SpatialiteDB.new(@project.get_path(:db))
  end

  def get_list_of_users
    users = @db.execute(WebQuery.get_list_of_users)
    users
  end

  def update_list_of_users(user)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      @db.execute(WebQuery.update_list_of_users, user.id, user.first_name, user.last_name)
      @project.db_mgr.make_dirt
    end
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

  def load_arch_entity(type, limit, offset, show_deleted)
    if show_deleted
      uuids = type.eql?('all') ?
          @db.execute(WebQuery.load_all_arch_entities_include_deleted, limit, offset) : @db.execute(WebQuery.load_arch_entities_include_deleted, type, limit, offset)
      uuids
    else
      uuids = type.eql?('all') ?
          @db.execute(WebQuery.load_all_arch_entities, limit, offset) : @db.execute(WebQuery.load_arch_entities, type, limit, offset)
      uuids
    end
  end

  def search_arch_entity(limit, offset, query, show_deleted)
    if show_deleted
      uuids = @db.execute(WebQuery.search_arch_entity_include_deleted, query, query, query, limit, offset)
      uuids
    else
      uuids = @db.execute(WebQuery.search_arch_entity, query, query, query, limit, offset)
      uuids
    end
  end

  def get_arch_entity_deleted_status(uuid)
    deleted = @db.execute(WebQuery.get_arch_entity_deleted_status, uuid).first
    deleted
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

  def update_arch_entity_attribute(uuid, userid, vocab_id, attribute_id, measure, freetext, certainty, ignore_errors = nil)
    @project.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      cache_timestamps = {}

      (0..(freetext.length-1)).each do |i|

        if cache_timestamps[attribute_id]
          parenttimestamp = cache_timestamps[attribute_id]
        else
          parenttimestamp = @db.get_first_value(WebQuery.get_aentvalue_parenttimestamp, uuid, attribute_id)

          cache_timestamps[attribute_id] = parenttimestamp
        end

        params = {
            uuid:uuid,
            userid:userid,
            attributeid:attribute_id,
            vocabid:vocab_id ? vocab_id[i] : nil,
            measure:measure[i],
            freetext:freetext[i],
            certainty:certainty[i],
            valuetimestamp:timestamp,
            parenttimestamp:parenttimestamp
        }

        @db.execute(WebQuery.insert_arch_entity_attribute, params)

      end

      validate_aent_value(uuid, timestamp, attribute_id) unless ignore_errors

      @project.db_mgr.make_dirt
    end
  end

  def update_aent_value_as_dirty(uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum, isdirty, isdirtyreason)
    @db.execute(WebQuery.update_aent_value_as_dirty, isdirty, isdirtyreason, uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum)
  end

  def insert_updated_arch_entity(uuid, userid, vocab_id, attribute_id, measure, freetext, certainty)
    @project.db_mgr.with_lock do
      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          uuid:uuid,
          userid:userid,
          aenttimestamp:timestamp
      }

      @db.execute(WebQuery.insert_arch_entity, params)

      cache_timestamps = {}

      (0..(freetext.length-1)).each do |i|

        if cache_timestamps[attribute_id[i]]
          parenttimestamp = cache_timestamps[attribute_id[i]]
        else
          parenttimestamp = @db.get_first_value(WebQuery.get_aentvalue_parenttimestamp, uuid, attribute_id[i])

          cache_timestamps[attribute_id[i]] = parenttimestamp
        end


        params = {
            uuid:uuid,
            userid:userid,
            attributeid:attribute_id[i],
            vocabid:vocab_id ? vocab_id[i] : nil,
            measure:measure[i],
            freetext:freetext[i],
            certainty:certainty[i],
            valuetimestamp:timestamp,
            parenttimestamp:parenttimestamp
        }

        @db.execute(WebQuery.insert_arch_entity_attribute, params)

        validate_aent_value(uuid, timestamp, attribute_id[i])
      end

      @project.db_mgr.make_dirt
    end
  end

  def get_arch_ent_history(uuid)
    timestamps = @db.execute(WebQuery.get_arch_ent_history, uuid, uuid)
    timestamps
  end

  def get_arch_ent_attributes_at_timestamp(uuid, timestamp)
    attributes =  @db.execute(WebQuery.get_arch_ent_attributes_at_timestamp, @project.get_settings['srid'].to_i, uuid, timestamp, uuid, timestamp)
    attributes
  end

  def get_arch_ent_attributes_changes_at_timestamp(uuid, timestamp)
    srid = @project.get_settings['srid'].to_i
    changes = @db.execute(WebQuery.get_arch_ent_attributes_changes_at_timestamp, uuid, timestamp, uuid, timestamp, srid,
                          uuid, timestamp, srid, uuid, timestamp, uuid, timestamp, uuid, timestamp, uuid, timestamp, uuid, timestamp)
    changes
  end

  def revert_arch_ent_to_timestamp(uuid, userid, revert_timestamp)
    @project.db_mgr.with_lock do
      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          uuid:uuid,
          userid:userid,
          aenttimestamp:timestamp,
          timestamp: revert_timestamp
      }

      @db.execute(WebQuery.insert_arch_ent_at_timestamp, params)

      @project.db_mgr.make_dirt
    end
  end

  def revert_aentvalues_to_timestamp(uuid, userid, attributeid, revert_timestamp)
    @project.db_mgr.with_lock do
      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          uuid:uuid,
          userid:userid,
          attributeid:attributeid,
          valuetimestamp:timestamp,
          timestamp: revert_timestamp,
          parenttimestamp: @db.get_first_value(WebQuery.get_aentvalue_parenttimestamp, uuid, attributeid)
      }

      @db.execute(WebQuery.insert_aentvalue_at_timestamp, params)

      @project.db_mgr.make_dirt
    end
  end

  def resolve_arch_ent_conflicts(uuid)
    @project.db_mgr.with_lock do

      @db.execute(WebQuery.clear_arch_ent_fork, uuid)
      @db.execute(WebQuery.clear_aentvalue_fork, uuid)

      @project.db_mgr.make_dirt
    end
  end

  def delete_arch_entity(uuid, userid)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      params = {
          userid:userid,
          deleted:'true',
          uuid:uuid
      }
      @db.execute(WebQuery.delete_or_undelete_arch_entity, params)
      @project.db_mgr.make_dirt
    end
  end

  def undelete_arch_entity(uuid, userid)
    @project.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      params = {
          userid:userid,
          deleted:nil,
          uuid:uuid
      }
      @db.execute(WebQuery.delete_or_undelete_arch_entity, params)
      @project.db_mgr.make_dirt
    end
  end

  def get_related_arch_entities(uuid)
    params = {
        uuid:uuid
    }
    related_arch_ents = @db.execute(WebQuery.get_related_arch_entities, params)
    related_arch_ents
  end

  def load_rel(type, limit, offset, show_deleted)
    if show_deleted
      relationshipids = type.eql?('all') ?
          @db.execute(WebQuery.load_all_relationships_include_deleted, limit, offset) : @db.execute(WebQuery.load_relationships_include_deleted, type, limit, offset)
      relationshipids
    else
      relationshipids = type.eql?('all') ?
          @db.execute(WebQuery.load_all_relationships, limit, offset) : @db.execute(WebQuery.load_relationships, type, limit, offset)
      relationshipids
    end
  end

  def search_rel(limit, offset, query, show_deleted)
    if show_deleted
      relationshipids = @db.execute(WebQuery.search_relationship_include_deleted, query, query, limit, offset)
      relationshipids
    else
      relationshipids = @db.execute(WebQuery.search_relationship, query, query, limit, offset)
      relationshipids
    end
  end

  def get_rel_deleted_status(relationshipid)
    deleted = @db.execute(WebQuery.get_rel_deleted_status, relationshipid).first
    deleted
  end

  def get_rel_attributes(relationshipid)
    attributes = @db.execute(WebQuery.get_relationship_attributes, relationshipid)
    attributes
  end

  def update_rel_attribute(relationshipid, userid, vocab_id, attribute_id, freetext, certainty, ignore_errors = nil)
    @project.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      cache_timestamps = {}

      (0..(freetext.length-1)).each do |i|

        if cache_timestamps[attribute_id]
          parenttimestamp = cache_timestamps[attribute_id]
        else
          parenttimestamp = @db.get_first_value(WebQuery.get_relnvalue_parenttimestamp, relationshipid, attribute_id)

          cache_timestamps[attribute_id] = parenttimestamp
        end

        params = {
            relationshipid:relationshipid,
            userid:userid,
            attributeid:attribute_id,
            vocabid:vocab_id ? vocab_id[i] : nil,
            freetext:freetext[i],
            certainty:certainty[i],
            relnvaluetimestamp:timestamp,
            parenttimestamp:parenttimestamp
        }

        @db.execute(WebQuery.insert_relationship_attribute, params)
      end

      validate_reln_value(relationshipid, timestamp, attribute_id) unless ignore_errors

      @project.db_mgr.make_dirt
    end
  end

  def update_reln_value_as_dirty(relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum, isdirty, isdirtyreason)
    @db.execute(WebQuery.update_reln_value_as_dirty, isdirty, isdirtyreason, relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum)
  end

  def insert_updated_rel(relationshipid, userid, vocab_id, attribute_id, freetext, certainty)
    @project.db_mgr.with_lock do
      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          relationshipid:relationshipid,
          userid:userid,
          relntimestamp:timestamp
      }

      @db.execute(WebQuery.insert_relationship, params)

      cache_timestamps = {}

      (0..(freetext.length-1)).each do |i|

        if cache_timestamps[attribute_id[i]]
          parenttimestamp = cache_timestamps[attribute_id[i]]
        else
          parenttimestamp = @db.get_first_value(WebQuery.get_relnvalue_parenttimestamp, relationshipid, attribute_id[i])

          cache_timestamps[attribute_id[i]] = parenttimestamp
        end

        params = {
            relationshipid:relationshipid,
            userid:userid,
            attributeid:attribute_id[i],
            vocabid:vocab_id ? vocab_id[i] : nil,
            freetext:freetext[i],
            certainty:certainty[i],
            relnvaluetimestamp:timestamp,
            parenttimestamp:parenttimestamp
        }

        @db.execute(WebQuery.insert_relationship_attribute, params)

        validate_reln_value(relationshipid, timestamp, attribute_id[i])
      end

      @project.db_mgr.make_dirt
    end
  end

  def get_rel_history(relid)
    timestamps = @db.execute(WebQuery.get_rel_history, relid, relid)
    timestamps
  end

  def get_rel_attributes_at_timestamp(relid, timestamp)
    attributes =  @db.execute(WebQuery.get_rel_attributes_at_timestamp, @project.get_settings['srid'].to_i, relid, timestamp, relid, timestamp)
    attributes
  end

  def get_rel_attributes_changes_at_timestamp(relid, timestamp)
    srid = @project.get_settings['srid'].to_i
    changes = @db.execute(WebQuery.get_rel_attributes_changes_at_timestamp, relid, timestamp, relid, timestamp, srid,
                          relid, timestamp, srid, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp)
    changes
  end

  def revert_rel_to_timestamp(relid, userid, revert_timestamp)
    @project.db_mgr.with_lock do
      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          relationshipid:relid,
          userid:userid,
          relntimestamp:timestamp,
          timestamp: revert_timestamp
      }

      @db.execute(WebQuery.insert_rel_at_timestamp, params)

      @project.db_mgr.make_dirt
    end
  end

  def revert_relnvalues_to_timestamp(relid, userid, attributeid, revert_timestamp)
    @project.db_mgr.with_lock do
      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          relationshipid:relid,
          userid:userid,
          attributeid:attributeid,
          relnvaluetimestamp:timestamp,
          timestamp: revert_timestamp,
          parenttimestamp: @db.get_first_value(WebQuery.get_relnvalue_parenttimestamp, relid, attributeid)
      }

      @db.execute(WebQuery.insert_relnvalue_at_timestamp, params)

      @project.db_mgr.make_dirt
    end
  end

  def resolve_rel_conflicts(relid)
    @project.db_mgr.with_lock do

      @db.execute(WebQuery.clear_rel_fork, relid)
      @db.execute(WebQuery.clear_relnvalue_fork, relid)

      @project.db_mgr.make_dirt
    end
  end

  def delete_relationship(relationshipid, userid)
    @project.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      params = {
          userid:userid,
          deleted:'true',
          relationshipid:relationshipid
      }
      @db.execute(WebQuery.delete_or_undelete_relationship, params)
      @project.db_mgr.make_dirt
    end
  end

  def undelete_relationship(relationshipid, userid)
    @project.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp)
      params = {
          userid:userid,
          deleted:nil,
          relationshipid:relationshipid
      }
      @db.execute(WebQuery.delete_or_undelete_relationship, params)
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

  def get_arch_ent_rel_associations(uuid, limit, offset)
    params = {
        uuid:uuid,
        limit:limit,
        offset:offset
    }
    rels = @db.execute(WebQuery.get_relationships_for_arch_ent, params)
    rels
  end

  def get_non_arch_ent_rel_associations(uuid, query, limit, offset)
    params = {
        uuid:uuid,
        limit:limit,
        query:query,
        offset:offset
    }
    rels = @db.execute(WebQuery.get_relationships_not_belong_to_arch_ent, params)
    rels
  end

  def add_member(relationshipid,userid, uuid, verb)
    @project.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          uuid:uuid,
          relationshipid:relationshipid,
          userid:userid,
          verb:verb,
          aentrelntimestamp:timestamp
      }

      @db.execute(WebQuery.insert_arch_entity_relationship, params)

      @project.db_mgr.make_dirt
    end
  end

  def delete_member(relationshipid,userid, uuid)
    @project.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp)

      params = {
          uuid:uuid,
          relationshipid:relationshipid,
          userid:userid,
          aentrelntimestamp:timestamp
      }

      @db.execute(WebQuery.delete_arch_entity_relationship, params)

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

      generate_template_db unless File.exists? Rails.root.join('lib/assets/template_db.sqlite3')
      FileUtils.cp Rails.root.join('lib/assets/template_db.sqlite3'), toDB # clone template db
      
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

  def is_arch_entity_forked(uuid)
    result = @db.get_first_value WebQuery.is_arch_entity_forked, uuid
    return true if result and result > 0
    result = @db.get_first_value WebQuery.is_aentvalue_forked, uuid
    return true if result and result > 0
    return false
  end

  def is_relationship_forked(relationshipid)
    result = @db.get_first_value WebQuery.is_relationship_forked, relationshipid
    return true if result and result > 0
    result = @db.get_first_value WebQuery.is_relnvalue_forked, relationshipid
    return true if result and result > 0
    return false
  end

  # static
  def self.generate_database(file, xml)
    generate_template_db unless File.exists? Rails.root.join('lib/assets/template_db.sqlite3')
    FileUtils.cp Rails.root.join('lib/assets/template_db.sqlite3'), file # clone template db
    db = SpatialiteDB.new(file)
    content = File.read(Rails.root.join('lib', 'assets', 'init.sql'))
    db.execute_batch(content)
    data_definition = XSLTParser.parse_data_schema(xml)
    db.execute_batch(data_definition)
    gps_definition = XSLTParser.parse_data_schema(Rails.root.join('lib/assets/gps_schema.xml'))
    db.execute_batch(gps_definition)
    admin_user = User.first
    db.execute("INSERT into user (userid,fname,lname) VALUES (" + admin_user.id.to_s + ",'" + admin_user.first_name.to_s + "','" + admin_user.last_name.to_s + "');" ) if admin_user
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

  def self.generate_spatial_ref_list
    temp = Tempfile.new('db')
    db = SpatialiteDB.new(temp.path)
    db.execute("SELECT InitSpatialMetaData();")
    result = db.execute("select srid || ' / ' || ref_sys_name, auth_srid from spatial_ref_sys;")
    FileUtils.rm Rails.root.join('lib/assets/spatial_ref_list.json') if File.exists? Rails.root.join('lib/assets/spatial_ref_list.json')
    File.open(Rails.root.join('lib/assets/spatial_ref_list.json'), 'w') do |f|
      f.write(result.to_json)
    end
  end

  def self.generate_template_db
    FileUtils.rm Rails.root.join('lib/assets/template_db.sqlite3') if File.exists? Rails.root.join('lib/assets/template_db.sqlite3')
    db = SpatialiteDB.new(Rails.root.join('lib/assets/template_db.sqlite3').to_s)
    db.execute("SELECT InitSpatialMetaData();")
  end

  def self.get_spatial_ref_list
    begin
      generate_spatial_ref_list unless File.exists? Rails.root.join('lib/assets/spatial_ref_list.json')
      return JSON.parse File.read(Rails.root.join('lib/assets/spatial_ref_list.json'))
    end
  end

  private

  def current_timestamp
    Time.now.getgm.strftime('%Y-%m-%d %H:%M:%S')
  end

end