require Rails.root.join('lib/spatialite_db')
require Rails.root.join('app/models/modules/web_query')

class Database

  LIMIT = 25

  def initialize(project_module)
    @project_module = project_module
    @db = SpatialiteDB.new(@project_module.get_path(:db))
  end

  def get_project_module_user_id(email)
    return @db.get_first_value(WebQuery.get_project_module_user_id, email)
  end

  def is_arch_ent_same_type(entity1, entity2)
     return @db.get_first_value(WebQuery.get_arch_entity_type, entity1) ==
         @db.get_first_value(WebQuery.get_arch_entity_type, entity2)
  end

  def is_rel_same_type(rel1, rel2)
    return @db.get_first_value(WebQuery.get_relationship_type, rel1) ==
        @db.get_first_value(WebQuery.get_relationship_type, rel2)
  end

  def get_list_of_users
    users = @db.execute(WebQuery.get_list_of_users)
    users
  end

  def update_list_of_users(user, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)
      @db.execute(WebQuery.update_list_of_users, user.first_name, user.last_name, user.email)
      @project_module.db_mgr.make_dirt
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

  def get_entity_identifier(uuid)
    @db.get_first_value(WebQuery.get_entity_identifier, uuid)
  end

  def get_rel_identifier(relationshipid)
    @db.get_first_value(WebQuery.get_rel_identifier, relationshipid)
  end

  def load_arch_entity(type, limit, offset, show_deleted)
    if type.eql?('all')
      params = {
          limit:limit,
          offset:offset
      }
      uuids = show_deleted ? @db.execute(WebQuery.load_all_arch_entities_include_deleted, params) : @db.execute(WebQuery.load_all_arch_entities, params)
    else
      params = {
          type:type,
          limit:limit,
          offset:offset
      }
      uuids = show_deleted ? @db.execute(WebQuery.load_arch_entities_include_deleted, params) : @db.execute(WebQuery.load_arch_entities, params)
    end
    uuids
  end

  def total_arch_entity(type, show_deleted)
    if type.eql?('all')
      total = show_deleted ? @db.get_first_value(WebQuery.total_all_arch_entities_include_deleted) : @db.get_first_value(WebQuery.total_all_arch_entities)
    else
      params = {
          type:type
      }
      total = show_deleted ? @db.get_first_value(WebQuery.total_arch_entities_include_deleted, params) : @db.get_first_value(WebQuery.total_arch_entities, params)
    end
    total
  end

  def search_arch_entity(limit, offset, query, show_deleted)
    params = {
        query:query,
        limit:limit,
        offset:offset
    }
    uuids = show_deleted ? @db.execute(WebQuery.search_arch_entity_include_deleted, params) :  @db.execute(WebQuery.search_arch_entity, params)
    uuids
  end

  def total_search_arch_entity(query, show_deleted)
    params = {
        query:query
    }
    total = show_deleted ? @db.get_first_value(WebQuery.total_search_arch_entity_include_deleted, params) :  @db.get_first_value(WebQuery.total_search_arch_entity, params)
    total
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
    @project_module.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp, userid)

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
            vocabid:clean(vocab_id ? vocab_id[i] : nil),
            measure:clean(measure[i]),
            freetext:clean(freetext[i]),
            certainty:clean(certainty[i]),
            valuetimestamp:timestamp,
            parenttimestamp:parenttimestamp
        }

        @db.execute(WebQuery.insert_arch_entity_attribute, params)

      end

      validate_aent_value(uuid, timestamp, attribute_id) unless ignore_errors

      @project_module.db_mgr.make_dirt
    end
  end

  def update_aent_value_as_dirty(uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum, isdirty, isdirtyreason)
    @db.execute(WebQuery.update_aent_value_as_dirty, isdirty, isdirtyreason, uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum)
  end

  def merge_arch_ents(delete_uuid, merge_uuid, vocab_id, attribute_id, measure, freetext, certainty, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)

      delete_arch_entity_no_lock(delete_uuid, userid)

      insert_updated_arch_entity(merge_uuid, userid, vocab_id, attribute_id, measure, freetext, certainty)

      @project_module.db_mgr.make_dirt
    end
  end

  def insert_updated_arch_entity(uuid, userid, vocab_id, attribute_id, measure, freetext, certainty)
    timestamp = current_timestamp

    params = {
        uuid:uuid,
        userid:userid,
        aenttimestamp:timestamp,
        parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
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
          vocabid:clean(vocab_id ? vocab_id[i] : nil),
          measure:clean(measure[i]),
          freetext:clean(freetext[i]),
          certainty:clean(certainty[i]),
          valuetimestamp:timestamp,
          parenttimestamp:parenttimestamp
      }

      @db.execute(WebQuery.insert_arch_entity_attribute, params)

      validate_aent_value(uuid, timestamp, attribute_id[i])
    end
  end

  def get_arch_ent_history(uuid)
    timestamps = @db.execute(WebQuery.get_arch_ent_history, uuid, uuid)
    timestamps
  end

  def get_arch_ent_attributes_at_timestamp(uuid, timestamp)
    attributes =  @db.execute(WebQuery.get_arch_ent_attributes_at_timestamp, @project_module.get_settings['srid'].to_i, uuid, timestamp, uuid, timestamp)
    attributes
  end

  def get_arch_ent_attributes_changes_at_timestamp(uuid, timestamp)
    srid = @project_module.get_settings['srid'].to_i
    changes = @db.execute(WebQuery.get_arch_ent_attributes_changes_at_timestamp, uuid, timestamp, uuid, timestamp, srid,
                          uuid, timestamp, srid, uuid, timestamp, uuid, timestamp, uuid, timestamp, uuid, timestamp, uuid, timestamp)
    changes
  end

  def revert_arch_ent(uuid, revert_timestamp, attributes, resolve, userid)
    @project_module.db_mgr.with_lock do
      timestamp = current_timestamp

      @db.execute(WebQuery.insert_version, timestamp, userid)

      revert_arch_ent_to_timestamp(uuid, userid, revert_timestamp, timestamp)

      attributes.each do | attribute |
        revert_aentvalues_to_timestamp(attribute[:uuid], userid, attribute[:attributeid], attribute[:timestamp], timestamp)
      end

      # clear conflicts
      resolve_arch_ent_conflicts(uuid) if resolve

      @project_module.db_mgr.make_dirt
    end
  end

  def revert_arch_ent_to_timestamp(uuid, userid, revert_timestamp, timestamp)
    params = {
        uuid:uuid,
        userid:userid,
        aenttimestamp:timestamp,
        timestamp: revert_timestamp,
        parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
    }

    @db.execute(WebQuery.insert_arch_ent_at_timestamp, params)
  end

  def revert_aentvalues_to_timestamp(uuid, userid, attributeid, revert_timestamp, timestamp)
    params = {
        uuid:uuid,
        userid:userid,
        attributeid:attributeid,
        valuetimestamp:timestamp,
        timestamp: revert_timestamp,
        parenttimestamp: @db.get_first_value(WebQuery.get_aentvalue_parenttimestamp, uuid, attributeid)
    }

    @db.execute(WebQuery.insert_aentvalue_at_timestamp, params)
  end

  def resolve_arch_ent_conflicts(uuid)
    @db.execute(WebQuery.clear_arch_ent_fork, uuid)
    @db.execute(WebQuery.clear_aentvalue_fork, uuid)
  end

  def delete_arch_entity(uuid, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)
      delete_arch_entity_no_lock(uuid, userid)
      @project_module.db_mgr.make_dirt
    end
  end

  def delete_arch_entity_no_lock(uuid, userid)
    params = {
        userid:userid,
        deleted:'true',
        uuid:uuid,
        parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
    }
    @db.execute(WebQuery.delete_or_undelete_arch_entity, params)
  end

  def undelete_arch_entity(uuid, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)
      params = {
          userid:userid,
          deleted:nil,
          uuid:uuid,
          parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
      }
      @db.execute(WebQuery.delete_or_undelete_arch_entity, params)
      @project_module.db_mgr.make_dirt
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
    if type.eql?('all')
      params = {
          limit:limit,
          offset:offset
      }
      relationshipids = show_deleted ? @db.execute(WebQuery.load_all_relationships_include_deleted, params) : @db.execute(WebQuery.load_all_relationships, params)
    else
      params = {
          type:type,
          limit:limit,
          offset:offset
      }
      relationshipids = show_deleted ? @db.execute(WebQuery.load_relationships_include_deleted, params) : @db.execute(WebQuery.load_relationships, params)
    end
    relationshipids
  end

  def total_rel(type, show_deleted)
    if type.eql?('all')
      total = show_deleted ? @db.get_first_value(WebQuery.total_all_relationships_include_deleted) : @db.get_first_value(WebQuery.total_all_relationships)
    else
      params = {
          type:type
      }
      total = show_deleted ? @db.get_first_value(WebQuery.total_relationships_include_deleted, params) : @db.get_first_value(WebQuery.total_relationships, params)
    end
    total
  end

  def search_rel(limit, offset, query, show_deleted)
    params = {
        query:query,
        limit:limit,
        offset:offset
    }
    relationshipids = show_deleted ? @db.execute(WebQuery.search_relationship_include_deleted, params): @db.execute(WebQuery.search_relationship, params)
    relationshipids
  end

  def total_search_rel(query, show_deleted)
    params = {
        query:query
    }
    total = show_deleted ? @db.get_first_value(WebQuery.total_search_relationship_include_deleted, params): @db.get_first_value(WebQuery.total_search_relationship, params)
    total
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
    @project_module.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp, userid)

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
            vocabid:clean(vocab_id ? vocab_id[i] : nil),
            freetext:clean(freetext[i]),
            certainty:clean(certainty[i]),
            relnvaluetimestamp:timestamp,
            parenttimestamp:parenttimestamp
        }

        @db.execute(WebQuery.insert_relationship_attribute, params)
      end

      validate_reln_value(relationshipid, timestamp, attribute_id) unless ignore_errors

      @project_module.db_mgr.make_dirt
    end
  end

  def update_reln_value_as_dirty(relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum, isdirty, isdirtyreason)
    @db.execute(WebQuery.update_reln_value_as_dirty, isdirty, isdirtyreason, relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum)
  end

  def merge_rel(deleted_relationshipid, merge_relationshipid, vocab_id, attribute_id, freetext, certainty, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)

      delete_relationship_no_lock(deleted_relationshipid, userid)

      insert_updated_rel(merge_relationshipid, userid, vocab_id, attribute_id, freetext, certainty)

      @project_module.db_mgr.make_dirt
    end
  end

  def insert_updated_rel(relationshipid, userid, vocab_id, attribute_id, freetext, certainty)
    timestamp = current_timestamp

    params = {
        relationshipid:relationshipid,
        userid:userid,
        relntimestamp:timestamp,
        parenttimestamp: @db.get_first_value(WebQuery.get_rel_parenttimestamp, relationshipid)
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
          vocabid:clean(vocab_id ? vocab_id[i] : nil),
          freetext:clean(freetext[i]),
          certainty:clean(certainty[i]),
          relnvaluetimestamp:timestamp,
          parenttimestamp:parenttimestamp
      }

      @db.execute(WebQuery.insert_relationship_attribute, params)

      validate_reln_value(relationshipid, timestamp, attribute_id[i])
    end
  end

  def get_rel_history(relid)
    timestamps = @db.execute(WebQuery.get_rel_history, relid, relid)
    timestamps
  end

  def get_rel_attributes_at_timestamp(relid, timestamp)
    attributes =  @db.execute(WebQuery.get_rel_attributes_at_timestamp, @project_module.get_settings['srid'].to_i, relid, timestamp, relid, timestamp)
    attributes
  end

  def get_rel_attributes_changes_at_timestamp(relid, timestamp)
    srid = @project_module.get_settings['srid'].to_i
    changes = @db.execute(WebQuery.get_rel_attributes_changes_at_timestamp, relid, timestamp, relid, timestamp, srid,
                          relid, timestamp, srid, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp)
    changes
  end

  def revert_rel(relid, revert_timestamp, attributes, resolve, userid)
    @project_module.db_mgr.with_lock do
      timestamp = @project_module.db.current_timestamp

      @db.execute(WebQuery.insert_version, timestamp, userid)

      revert_rel_to_timestamp(relid, userid, revert_timestamp, timestamp)

      attributes.each do | attribute |
        revert_relnvalues_to_timestamp(attribute[:relationshipid], userid, attribute[:attributeid], attribute[:timestamp], timestamp)
      end

      # clear conflicts
      resolve_rel_conflicts(relid) if resolve

      @project_module.db_mgr.make_dirt
    end
  end

  def revert_rel_to_timestamp(relid, userid, revert_timestamp, timestamp)
    params = {
        relationshipid:relid,
        userid:userid,
        relntimestamp:timestamp,
        timestamp: revert_timestamp,
        parenttimestamp: @db.get_first_value(WebQuery.get_rel_parenttimestamp, relid)
    }

    @db.execute(WebQuery.insert_rel_at_timestamp, params)
  end

  def revert_relnvalues_to_timestamp(relid, userid, attributeid, revert_timestamp, timestamp)
    params = {
        relationshipid:relid,
        userid:userid,
        attributeid:attributeid,
        relnvaluetimestamp:timestamp,
        timestamp: revert_timestamp,
        parenttimestamp: @db.get_first_value(WebQuery.get_relnvalue_parenttimestamp, relid, attributeid)
    }

    @db.execute(WebQuery.insert_relnvalue_at_timestamp, params)
  end

  def resolve_rel_conflicts(relid)
    @db.execute(WebQuery.clear_rel_fork, relid)
    @db.execute(WebQuery.clear_relnvalue_fork, relid)
  end

  def delete_relationship(relationshipid, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)
      delete_relationship_no_lock(relationshipid, userid)
      @project_module.db_mgr.make_dirt
    end
  end

  def delete_relationship_no_lock(relationshipid, userid)
    params = {
        userid:userid,
        deleted:'true',
        relationshipid:relationshipid,
        parenttimestamp: @db.get_first_value(WebQuery.get_rel_parenttimestamp, relationshipid)
    }
    @db.execute(WebQuery.delete_or_undelete_relationship, params)
  end

  def undelete_relationship(relationshipid, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)
      params = {
          userid:userid,
          deleted:nil,
          relationshipid:relationshipid,
          parenttimestamp: @db.get_first_value(WebQuery.get_rel_parenttimestamp, relationshipid)
      }
      @db.execute(WebQuery.delete_or_undelete_relationship, params)
      @project_module.db_mgr.make_dirt
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
    params = {
        relationshipid:relationshipid,
        limit:limit,
        offset:offset
    }
    uuids = @db.execute(WebQuery.get_arch_entities_in_relationship, params)
    uuids
  end

  def total_rel_arch_ent_members(relationshipid)
    params = {
        relationshipid:relationshipid
    }
    total = @db.get_first_value(WebQuery.total_arch_entities_in_relationship, params)
    total
  end

  def get_non_member_arch_ent(relationshipid, query, limit, offset)
    params = {
        query:query,
        relationshipid:relationshipid,
        limit:limit,
        offset:offset
    }
    uuids = @db.execute(WebQuery.get_arch_entities_not_in_relationship, params)
    uuids
  end

  def total_non_member_arch_ent(relationshipid, query)
    params = {
        query:query,
        relationshipid:relationshipid
    }
    total = @db.get_first_value(WebQuery.total_arch_entities_not_in_relationship, params)
    total
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

  def total_arch_ent_rel_associations(uuid)
    params = {
        uuid:uuid
    }
    total = @db.get_first_value(WebQuery.total_relationships_for_arch_ent, params)
    total
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

  def total_non_arch_ent_rel_associations(uuid, query)
    params = {
        uuid:uuid,
        query:query
    }
    total = @db.get_first_value(WebQuery.total_relationships_not_belong_to_arch_ent, params)
    total
  end

  def add_member(relationshipid, userid, uuid, verb)
    @project_module.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp, userid)

      params = {
          uuid:uuid,
          relationshipid:relationshipid,
          userid:userid,
          verb:clean(verb),
          aentrelntimestamp:timestamp,
          parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_rel_parenttimestamp, uuid, relationshipid)
      }

      @db.execute(WebQuery.insert_arch_entity_relationship, params)

      @project_module.db_mgr.make_dirt
    end
  end

  def delete_member(relationshipid, userid, uuid)
    @project_module.db_mgr.with_lock do

      timestamp = current_timestamp
      @db.execute(WebQuery.insert_version, timestamp, userid)

      params = {
          uuid:uuid,
          relationshipid:relationshipid,
          userid:userid,
          aentrelntimestamp:timestamp,
          parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_rel_parenttimestamp, uuid, relationshipid)
      }

      @db.execute(WebQuery.delete_arch_entity_relationship, params)

      @project_module.db_mgr.make_dirt
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
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_user_version, current_timestamp, userid)
      @project_module.db_mgr.make_dirt
      latest_version
    end
  end

  def merge_database(fromDB, version)
    @project_module.db_mgr.with_lock do
      @db.execute_batch(WebQuery.merge_database(fromDB, version))

      validate_records
      @project_module.db_mgr.make_dirt
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

  def update_attributes_vocab(attribute_id, temp_id, temp_parent_id, vocab_id, parent_vocab_id, vocab_name, vocab_description, picture_url, userid)
    @project_module.db_mgr.with_lock do
      @db.execute(WebQuery.insert_version, current_timestamp, userid)
      temp_id_vocab_mapping = {}
      vocab_id.length.times do |i|
        vocab_id[i] = vocab_id[i].blank? ? nil : vocab_id[i]
        parent_vocab_ids = parent_vocab_id[i].blank? ? temp_id_vocab_mapping[temp_parent_id[i]] : parent_vocab_id[i]
        @db.execute(WebQuery.update_attributes_vocab, vocab_id[i], attribute_id,vocab_name[i], vocab_description[i], picture_url[i], parent_vocab_ids)
        if !temp_id[i].blank?
          new_vocab_id = @db.last_insert_row_id
          temp_id_vocab_mapping[temp_id[i]] = new_vocab_id
        end
      end
      @project_module.db_mgr.make_dirt
    end
  end

  def create_app_database(toDB)
    fromDB = @project_module.get_path(:db)
    FileUtils.cp(fromDB,toDB)
  end

  def create_app_database_from_version(toDB, version)
    if version.to_i == 0
      FileUtils.cp path, toDB
    else
      @db.execute_batch(WebQuery.create_app_database_from_version(toDB, version))
    end
  end

  def validate_reln_value(relationshipid, relnvaluetimestamp, attributeid)
    return unless File.exists? @project_module.get_path(:validation_schema)
    begin
      db_validator = DatabaseValidator.new(self, @project_module.get_path(:validation_schema))

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
    return unless File.exists? @project_module.get_path(:validation_schema)
    begin
      db_validator = DatabaseValidator.new(self, @project_module.get_path(:validation_schema))

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
  def self.generate_database(file, xml, admin_user = nil)
    generate_template_db unless File.exists? Rails.root.join('lib/assets/template_db.sqlite3')
    FileUtils.cp Rails.root.join('lib/assets/template_db.sqlite3'), file # clone template db
    db = SpatialiteDB.new(file)
    content = File.read(Rails.root.join('lib', 'assets', 'init.sql'))
    db.execute_batch(content)
    data_definition = XSLTParser.parse_data_schema(xml)
    db.execute_batch(data_definition)
    db.execute("INSERT into user (fname,lname,email) VALUES ('#{admin_user.first_name}','#{admin_user.last_name}','#{admin_user.email}');" ) if admin_user
  end

  def spatialite_db
    @db
  end

  def spatialite_db=(value)
    @db = value
  end

  def project_module
    @project_module
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

  def current_timestamp
    Time.now.getgm.strftime('%Y-%m-%d %H:%M:%S')
  end

  def clean(value)
    return nil if value.blank?
    value
  end

end