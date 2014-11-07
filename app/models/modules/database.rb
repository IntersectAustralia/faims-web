require Rails.root.join('lib/spatialite_db')
require Rails.root.join('app/models/modules/web_query')

class Database

  LIMIT = 25

  def initialize(project_module)
    @project_module = project_module
    @db = SpatialiteDB.new(@project_module.get_path(:db))
  end

  def project_module
    @project_module
  end

  def spatialite_db
    @db
  end

  def path
    @db.path
  end

  # USER QUERIES

  def get_list_of_users
    users = @db.execute(WebQuery.get_list_of_users)
    users
  end

  def get_list_of_users_with_deleted
    users = @db.execute(WebQuery.get_list_of_users_with_deleted)
    users
  end

  def get_project_module_user_id(email)
    return @db.get_first_value(WebQuery.get_project_module_user_id, email)
  end

  def update_list_of_users(user, userid)
    @db.transaction do |db|
      db.execute(WebQuery.insert_version, current_timestamp, userid)
      params = {
          firstname:user.first_name,
          lastname:user.last_name,
          email:user.email
      }
      db.execute(WebQuery.update_list_of_users, params)
    end
  end

  def remove_user(delete_id, userid)
    @db.transaction do |db|
      unless get_list_of_users.count == 1
        db.execute(WebQuery.insert_version, current_timestamp, userid)
        db.execute(WebQuery.remove_user, delete_id)
      end
    end
  end

  # ENTITY AND RELATIONSHIP QUERIES

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

  def is_arch_ent_same_type(entity1, entity2)
     return @db.get_first_value(WebQuery.get_arch_entity_type, entity1) ==
         @db.get_first_value(WebQuery.get_arch_entity_type, entity2)
  end

  def is_rel_same_type(rel1, rel2)
    return @db.get_first_value(WebQuery.get_relationship_type, rel1) ==
        @db.get_first_value(WebQuery.get_relationship_type, rel2)
  end

  def is_arch_entity_dirty(uuid)
    @db.get_first_value(WebQuery.is_arch_entity_dirty, uuid, uuid)
  end

  def is_relationship_dirty(relationshipid)
    @db.get_first_value(WebQuery.is_relationship_dirty, relationshipid)
  end

  def get_arch_entity_type(uuid)
    @db.get_first_value(WebQuery.get_arch_entity_type, uuid)
  end

  def get_relationship_type(relationshipid)
    @db.get_first_value(WebQuery.get_relationship_type, relationshipid)
  end

  def get_entity_identifier(uuid)
    @db.get_first_value(WebQuery.get_entity_identifier, uuid)
  end

  def get_rel_identifier(relationshipid)
    @db.get_first_value(WebQuery.get_rel_identifier, relationshipid)
  end

  def search_arch_entity(limit, offset, type, user, query, show_deleted)
    params = {
        type:type,
        user:user,
        query:query,
        limit:limit,
        offset:offset
    }
    uuids = show_deleted ? @db.execute(WebQuery.search_arch_entity_include_deleted, params) : @db.execute(WebQuery.search_arch_entity, params)
    uuids
  end

  def total_search_arch_entity(type, user, query, show_deleted)
    params = {
        type:type,
        user:user,
        query:query
    }
    total = show_deleted ? @db.get_first_value(WebQuery.total_search_arch_entity_include_deleted, params) : @db.get_first_value(WebQuery.total_search_arch_entity, params)
    total
  end

  def get_arch_entity_deleted_status(uuid)
    @db.execute(WebQuery.get_arch_entity_deleted_status, uuid).first
  end

  def get_arch_entity_attributes(uuid)
    attributes = @db.execute(WebQuery.get_arch_entity_attributes, uuid)
    attributes
  end

  def get_arch_ent_info(uuid)
    info = @db.execute(WebQuery.get_arch_ent_info, uuid)
    info
  end

  def get_arch_ent_attribute_info(uuid, valuetimestamp, attribute_id)
    info = @db.execute(WebQuery.get_arch_ent_attribute_info, uuid, valuetimestamp, attribute_id)
    info
  end

  def get_arch_ent_attribute_for_comparison(uuid)
    attributes = @db.execute(WebQuery.get_arch_ent_attribute_for_comparison, uuid)
    attributes
  end

  def update_arch_entity_attribute(db, timestamp, uuid, userid, vocab_id, attribute_id, measure, freetext, certainty, ignore_errors = nil)
    db.execute(WebQuery.insert_version, timestamp, userid)

    cache_timestamps = {}

    (0..(freetext.length-1)).each do |i|

      if cache_timestamps[attribute_id]
        parenttimestamp = cache_timestamps[attribute_id]
      else
        parenttimestamp = db.get_first_value(WebQuery.get_aentvalue_parenttimestamp, uuid, attribute_id)

        cache_timestamps[attribute_id] = parenttimestamp
      end

      # check if deleted
      v = clean(vocab_id ? vocab_id[i] : nil)
      m = clean(measure[i])
      f = clean(freetext[i])
      c = clean(certainty[i])
      deleted = v.blank? && m.blank? && f.blank? && c.blank?

      params = {
          uuid:uuid,
          userid:userid,
          attributeid:attribute_id,
          vocabid:v,
          measure:m,
          freetext:f,
          certainty:c,
          valuetimestamp:timestamp,
          parenttimestamp:parenttimestamp,
          deleted: deleted ? 1 : nil
      }

      db.execute(WebQuery.insert_arch_entity_attribute, params)
    end

    validate_aent_value(db, uuid, timestamp, attribute_id) unless ignore_errors
  end

  def update_aent_value_as_dirty(db, uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum, isdirty, isdirtyreason)
    db.execute(WebQuery.update_aent_value_as_dirty, isdirty, isdirtyreason, uuid, valuetimestamp, userid, attribute_id, vocab_id, measure, freetext, certainty, versionnum)
  end

  def merge_arch_ents(delete_uuid, merge_uuid, vocab_id, attribute_id, measure, freetext, certainty, userid)
    @db.transaction do |db|
      db.execute(WebQuery.insert_version, current_timestamp, userid)

      delete_arch_entity_no_transaction(db, delete_uuid, userid)

      insert_updated_arch_entity(db, merge_uuid, userid, vocab_id, attribute_id, measure, freetext, certainty)

      merge_arch_entity_relationships(db, merge_uuid, delete_uuid)
    end
  end

  def merge_arch_entity_relationships(db, merge_uuid, delete_uuid)
    params = {
        mergeuuid:merge_uuid,
        deleteuuid:delete_uuid
    }
    # copies over relationships
    db.execute(WebQuery.merge_copy_arch_entity_relationships, params)
    # marks redundant relationships as deleted
    db.execute(WebQuery.merge_delete_arch_entity_relationships, {deleteuuid:delete_uuid})
  end

  def insert_updated_arch_entity(db, uuid, userid, vocab_id, attribute_id, measure, freetext, certainty)
    timestamp = current_timestamp

    params = {
        uuid:uuid,
        userid:userid,
        aenttimestamp:timestamp,
        parenttimestamp: db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
    }

    db.execute(WebQuery.insert_arch_entity, params)

    cache_timestamps = {}

    (0..(freetext.length-1)).each do |i|

      if cache_timestamps[attribute_id[i]]
        parenttimestamp = cache_timestamps[attribute_id[i]]
      else
        parenttimestamp = db.get_first_value(WebQuery.get_aentvalue_parenttimestamp, uuid, attribute_id[i])

        cache_timestamps[attribute_id[i]] = parenttimestamp
      end

      # check if deleted
      v = clean(vocab_id ? vocab_id[i] : nil)
      m = clean(measure[i])
      f = clean(freetext[i])
      c = clean(certainty[i])
      deleted = v.blank? && m.blank? && f.blank? && c.blank?

      params = {
          uuid:uuid,
          userid:userid,
          attributeid:attribute_id[i],
          vocabid:v,
          measure:m,
          freetext:f,
          certainty:c,
          valuetimestamp:timestamp,
          parenttimestamp:parenttimestamp,
          deleted: deleted ? 1 : nil
      }

      db.execute(WebQuery.insert_arch_entity_attribute, params)

      validate_aent_value(db, uuid, timestamp, attribute_id[i])
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
    @db.transaction do |db|
      timestamp = current_timestamp

      db.execute(WebQuery.insert_version, timestamp, userid)

      revert_arch_ent_to_timestamp(db, uuid, userid, revert_timestamp, timestamp)

      attributes.each do | attribute |
        revert_aentvalues_to_timestamp(db, attribute[:uuid], userid, attribute[:attributeid], attribute[:timestamp], timestamp)
      end

      # clear conflicts
      resolve_arch_ent_conflicts(db, uuid) if resolve
    end
  end

  def revert_arch_ent_to_timestamp(db, uuid, userid, revert_timestamp, timestamp)
    params = {
        uuid:uuid,
        userid:userid,
        aenttimestamp:timestamp,
        timestamp: revert_timestamp,
        parenttimestamp: db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
    }

    db.execute(WebQuery.insert_arch_ent_at_timestamp, params)
  end

  def revert_aentvalues_to_timestamp(db, uuid, userid, attributeid, revert_timestamp, timestamp)
    params = {
        uuid:uuid,
        userid:userid,
        attributeid:attributeid,
        valuetimestamp:timestamp,
        timestamp: revert_timestamp,
        parenttimestamp: db.get_first_value(WebQuery.get_aentvalue_parenttimestamp, uuid, attributeid)
    }

    db.execute(WebQuery.insert_aentvalue_at_timestamp, params)
  end

  def resolve_arch_ent_conflicts(db, uuid)
    db.execute(WebQuery.clear_arch_ent_fork, uuid)
    db.execute(WebQuery.clear_aentvalue_fork, uuid)
  end

  def delete_arch_entity(uuid, userid)
    @db.transaction do |db|
      delete_arch_entity_no_transaction(db, uuid, userid)
    end
  end

  def delete_arch_entity_no_transaction(db, uuid, userid)
    db.execute(WebQuery.insert_version, current_timestamp, userid)
    params = {
        userid:userid,
        deleted:'true',
        uuid:uuid,
        parenttimestamp: db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
    }
    db.execute(WebQuery.delete_or_restore_arch_entity, params)
  end

  def restore_arch_entity(uuid, userid)
    @db.transaction do |db|
      restore_arch_entity_no_transaction(db, uuid, userid)
    end
  end

  def restore_arch_entity_no_transaction(db, uuid, userid)
    db.execute(WebQuery.insert_version, current_timestamp, userid)
    params = {
        userid:userid,
        deleted:nil,
        uuid:uuid,
        parenttimestamp: db.get_first_value(WebQuery.get_arch_ent_parenttimestamp, uuid)
    }
    db.execute(WebQuery.delete_or_restore_arch_entity, params)
  end

  def batch_delete_arch_entities(uuids, userid)
    @db.transaction do |db|
      uuids.each do |uuid|
        delete_arch_entity_no_transaction(db, uuid, userid)
      end
    end
  end

  def batch_restore_arch_entities(uuids, userid)
    @db.transaction do |db|
      uuids.each do |uuid|
        restore_arch_entity_no_transaction(db, uuid, userid)
      end
    end
  end

  def delete_related_arch_entity_no_transaction(db, relnid, userid)
    db.execute(WebQuery.insert_version, current_timestamp, userid)
    db.execute(WebQuery.delete_related_arch_entity, relnid)
  end

  def restore_related_arch_entity_no_transaction(db, relnid, userid)
    db.execute(WebQuery.insert_version, current_timestamp, userid)
    db.execute(WebQuery.restore_related_arch_entity, relnid)
  end

  def batch_delete_related_arch_entities(reln_ids, userid)
    @db.transaction do |db|
      reln_ids.each do |relnid|
        delete_related_arch_entity_no_transaction(db, relnid, userid)
      end
    end
  end

  def batch_restore_related_arch_entities(reln_ids, userid)
    @db.transaction do |db|
      reln_ids.each do |uuid|
        restore_related_arch_entity_no_transaction(db, uuid, userid)
      end
    end
  end

  def get_related_arch_entities(uuid, show_deleted)
    params = {
        uuid:uuid
    }
    related_arch_ents = show_deleted ? @db.execute(WebQuery.get_related_arch_entities_include_deleted, params) : @db.execute(WebQuery.get_related_arch_entities, params)
    related_arch_ents
  end

  # def load_rel(type, limit, offset, show_deleted)
  #   if type.eql?('all')
  #     params = {
  #         limit:limit,
  #         offset:offset
  #     }
  #     relationshipids = show_deleted ? @db.execute(WebQuery.load_all_relationships_include_deleted, params) : @db.execute(WebQuery.load_all_relationships, params)
  #   else
  #     params = {
  #         type:type,
  #         limit:limit,
  #         offset:offset
  #     }
  #     relationshipids = show_deleted ? @db.execute(WebQuery.load_relationships_include_deleted, params) : @db.execute(WebQuery.load_relationships, params)
  #   end
  #   relationshipids
  # end

  # def search_rel(limit, offset, query, show_deleted)
  #   params = {
  #       query:query,
  #       limit:limit,
  #       offset:offset
  #   }
  #   relationshipids = show_deleted ? @db.execute(WebQuery.search_relationship_include_deleted, params): @db.execute(WebQuery.search_relationship, params)
  #   relationshipids
  # end

  # def total_rel(type, show_deleted)
  #   if type.eql?('all')
  #     total = show_deleted ? @db.get_first_value(WebQuery.total_all_relationships_include_deleted) : @db.get_first_value(WebQuery.total_all_relationships)
  #   else
  #     params = {
  #         type:type
  #     }
  #     total = show_deleted ? @db.get_first_value(WebQuery.total_relationships_include_deleted, params) : @db.get_first_value(WebQuery.total_relationships, params)
  #   end
  #   total
  # end

  # def total_search_rel(query, show_deleted)
  #   params = {
  #       query:query
  #   }
  #   total = show_deleted ? @db.get_first_value(WebQuery.total_search_relationship_include_deleted, params): @db.get_first_value(WebQuery.total_search_relationship, params)
  #   total
  # end

  # def get_rel_deleted_status(relationshipid)
  #   @db.execute(WebQuery.get_rel_deleted_status, relationshipid).first
  # end

  def get_rel_attributes(relationshipid)
    attributes = @db.execute(WebQuery.get_relationship_attributes, relationshipid)
    attributes
  end

  # def update_rel_attribute(relationshipid, userid, vocab_id, attribute_id, freetext, certainty, ignore_errors = nil)
  #   @db.transaction do |db|

  #     timestamp = current_timestamp
  #     db.execute(WebQuery.insert_version, timestamp, userid)

  #     cache_timestamps = {}

  #     (0..(freetext.length-1)).each do |i|

  #       if cache_timestamps[attribute_id]
  #         parenttimestamp = cache_timestamps[attribute_id]
  #       else
  #         parenttimestamp = db.get_first_value(WebQuery.get_relnvalue_parenttimestamp, relationshipid, attribute_id)

  #         cache_timestamps[attribute_id] = parenttimestamp
  #       end

  #       params = {
  #           relationshipid:relationshipid,
  #           userid:userid,
  #           attributeid:attribute_id,
  #           vocabid:clean(vocab_id ? vocab_id[i] : nil),
  #           freetext:clean(freetext[i]),
  #           certainty:clean(certainty[i]),
  #           relnvaluetimestamp:timestamp,
  #           parenttimestamp:parenttimestamp
  #       }

  #       db.execute(WebQuery.insert_relationship_attribute, params)
  #     end

  #     validate_reln_value(db, relationshipid, timestamp, attribute_id) unless ignore_errors
  #   end
  # end

  # def update_reln_value_as_dirty(db, relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum, isdirty, isdirtyreason)
  #   db.execute(WebQuery.update_reln_value_as_dirty, isdirty, isdirtyreason, relationshipid, relnvaluetimestamp, userid, attribute_id, vocab_id, freetext, certainty, versionnum)
  # end

  # def merge_rel(deleted_relationshipid, merge_relationshipid, vocab_id, attribute_id, freetext, certainty, userid)
  #   @db.transaction do |db|
  #     db.execute(WebQuery.insert_version, current_timestamp, userid)

  #     delete_relationship_no_transaction(db, deleted_relationshipid, userid)

  #     insert_updated_rel(db, merge_relationshipid, userid, vocab_id, attribute_id, freetext, certainty)
  #   end
  # end

  # def insert_updated_rel(db, relationshipid, userid, vocab_id, attribute_id, freetext, certainty)
  #   timestamp = current_timestamp

  #   params = {
  #       relationshipid:relationshipid,
  #       userid:userid,
  #       relntimestamp:timestamp,
  #       parenttimestamp: db.get_first_value(WebQuery.get_rel_parenttimestamp, relationshipid)
  #   }

  #   db.execute(WebQuery.insert_relationship, params)

  #   cache_timestamps = {}

  #   (0..(freetext.length-1)).each do |i|

  #     if cache_timestamps[attribute_id[i]]
  #       parenttimestamp = cache_timestamps[attribute_id[i]]
  #     else
  #       parenttimestamp = db.get_first_value(WebQuery.get_relnvalue_parenttimestamp, relationshipid, attribute_id[i])

  #       cache_timestamps[attribute_id[i]] = parenttimestamp
  #     end

  #     params = {
  #         relationshipid:relationshipid,
  #         userid:userid,
  #         attributeid:attribute_id[i],
  #         vocabid:clean(vocab_id ? vocab_id[i] : nil),
  #         freetext:clean(freetext[i]),
  #         certainty:clean(certainty[i]),
  #         relnvaluetimestamp:timestamp,
  #         parenttimestamp:parenttimestamp
  #     }

  #     db.execute(WebQuery.insert_relationship_attribute, params)

  #     validate_reln_value(db, relationshipid, timestamp, attribute_id[i])
  #   end
  # end

  # def get_rel_history(relid)
  #   timestamps = @db.execute(WebQuery.get_rel_history, relid, relid)
  #   timestamps
  # end

  def get_rel_attributes_at_timestamp(relid, timestamp)
    attributes =  @db.execute(WebQuery.get_rel_attributes_at_timestamp, @project_module.get_settings['srid'].to_i, relid, timestamp, relid, timestamp)
    attributes
  end

  # def get_rel_attributes_changes_at_timestamp(relid, timestamp)
  #   srid = @project_module.get_settings['srid'].to_i
  #   changes = @db.execute(WebQuery.get_rel_attributes_changes_at_timestamp, relid, timestamp, relid, timestamp, srid,
  #                         relid, timestamp, srid, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp, relid, timestamp)
  #   changes
  # end

  # def revert_rel(relid, revert_timestamp, attributes, resolve, userid)
  #   @db.transaction do |db|
  #     timestamp = current_timestamp

  #     db.execute(WebQuery.insert_version, timestamp, userid)

  #     revert_rel_to_timestamp(db, relid, userid, revert_timestamp, timestamp)

  #     attributes.each do | attribute |
  #       revert_relnvalues_to_timestamp(db, attribute[:relationshipid], userid, attribute[:attributeid], attribute[:timestamp], timestamp)
  #     end

  #     # clear conflicts
  #     resolve_rel_conflicts(db, relid) if resolve
  #   end
  # end

  # def revert_rel_to_timestamp(db, relid, userid, revert_timestamp, timestamp)
  #   params = {
  #       relationshipid:relid,
  #       userid:userid,
  #       relntimestamp:timestamp,
  #       timestamp: revert_timestamp,
  #       parenttimestamp: db.get_first_value(WebQuery.get_rel_parenttimestamp, relid)
  #   }

  #   db.execute(WebQuery.insert_rel_at_timestamp, params)
  # end

  # def revert_relnvalues_to_timestamp(db, relid, userid, attributeid, revert_timestamp, timestamp)
  #   params = {
  #       relationshipid:relid,
  #       userid:userid,
  #       attributeid:attributeid,
  #       relnvaluetimestamp:timestamp,
  #       timestamp: revert_timestamp,
  #       parenttimestamp: db.get_first_value(WebQuery.get_relnvalue_parenttimestamp, relid, attributeid)
  #   }

  #   db.execute(WebQuery.insert_relnvalue_at_timestamp, params)
  # end

  # def resolve_rel_conflicts(db, relid)
  #   db.execute(WebQuery.clear_rel_fork, relid)
  #   db.execute(WebQuery.clear_relnvalue_fork, relid)
  # end

  # def delete_relationship(relationshipid, userid)
  #   @db.transaction do |db|
  #     db.execute(WebQuery.insert_version, current_timestamp, userid)
  #     delete_relationship_no_transaction(db, relationshipid, userid)
  #   end
  # end

  # def delete_relationship_no_transaction(db, relationshipid, userid)
  #   params = {
  #       userid:userid,
  #       deleted:'true',
  #       relationshipid:relationshipid,
  #       parenttimestamp: db.get_first_value(WebQuery.get_rel_parenttimestamp, relationshipid)
  #   }
  #   db.execute(WebQuery.delete_or_restore_relationship, params)
  # end

  # def restore_relationship(relationshipid, userid)
  #   @db.transaction do |db|
  #     db.execute(WebQuery.insert_version, current_timestamp, userid)
  #     params = {
  #         userid:userid,
  #         deleted:nil,
  #         relationshipid:relationshipid,
  #         parenttimestamp: db.get_first_value(WebQuery.get_rel_parenttimestamp, relationshipid)
  #     }
  #     db.execute(WebQuery.delete_or_restore_relationship, params)
  #   end
  # end

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
    @db.transaction do |db|

      timestamp = current_timestamp
      db.execute(WebQuery.insert_version, timestamp, userid)

      params = {
          uuid:uuid,
          relationshipid:relationshipid,
          userid:userid,
          verb:clean(verb),
          aentrelntimestamp:timestamp,
          parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_rel_parenttimestamp, uuid, relationshipid)
      }

      db.execute(WebQuery.insert_arch_entity_relationship, params)
    end
  end

  def delete_member(relationshipid, userid, uuid)
    @db.transaction do |db|

      timestamp = current_timestamp
      db.execute(WebQuery.insert_version, timestamp, userid)

      params = {
          uuid:uuid,
          relationshipid:relationshipid,
          userid:userid,
          aentrelntimestamp:timestamp,
          parenttimestamp: @db.get_first_value(WebQuery.get_arch_ent_rel_parenttimestamp, uuid, relationshipid)
      }

      db.execute(WebQuery.delete_arch_entity_relationship, params)
    end
  end

  def get_arch_ent_types
    types = @db.execute(WebQuery.get_arch_entity_types)
    types
  end

  def get_rel_types
    types = @db.execute(WebQuery.get_relationship_types)
    types
  end

  def attribute_has_thumbnail(attribute_id)
    result = @db.execute(WebQuery.attribute_has_thumbnail, attribute_id)
    result[0][0] > 0
  end

  def attribute_is_sync(attribute_id)
    result = @db.execute(WebQuery.attribute_is_sync, attribute_id)
    result[0][0] > 0
  end

  # VOCABULARY QUERIES

  def get_vocab(attributeid)
    vocabs = @db.execute(WebQuery.get_vocab, attributeid)
    vocabs
  end

  def get_attributes_containing_vocab
    attributes = @db.execute(WebQuery.get_attributes_containing_vocab)
    attributes
  end

  def get_vocabs_for_attribute(attribute_id)
    vocabs = @db.execute(WebQuery.get_vocabs_for_attribute, attribute_id)
    vocabs
  end

  def update_attributes_vocab(attribute_id, temp_id, parent_temp_id, vocab_id, parent_vocab_id, vocab_name, vocab_description, picture_url, userid)
    @db.transaction do |db|
      db.execute(WebQuery.insert_version, current_timestamp, userid)
      temp_id_vocab_mapping = {}

      vocab_index_mapping = {}

      vocab_id.length.times do |i|
        vocab_id[i] = vocab_id[i].blank? ? nil : vocab_id[i]

        parent_vocab_ids = parent_vocab_id[i].blank? ? temp_id_vocab_mapping[parent_temp_id[i]] : parent_vocab_id[i]

        vocab_index_mapping[parent_vocab_ids] = vocab_index_mapping[parent_vocab_ids] ? vocab_index_mapping[parent_vocab_ids] + 1 : 1

        db.execute(WebQuery.update_attributes_vocab, vocab_id[i], attribute_id, vocab_name[i], vocab_description[i], picture_url[i], parent_vocab_ids, vocab_index_mapping[parent_vocab_ids])

        unless temp_id[i].blank?
          new_vocab_id = db.last_insert_row_id
          temp_id_vocab_mapping[temp_id[i]] = new_vocab_id
        end
      end
    end
  end

  # FILE HELPERS

  def get_files(type)
    files = []
    @db.execute(WebQuery.get_files_for_type, type).each do |result|
      files << {
          filename: result[0],
          md5checksum: result[1],
          size: result[2],
          type: result[3],
          state: result[4],
          timestamp: result[5],
          deleted: result[6],
          thumbnail_filename: result[7],
          thumbnail_md5checksum: result[8],
          thumbnail_size: result[9],
      }
    end
    files
  end

  def insert_file(info)
    @db.transaction do |db|
      db.execute(WebQuery.insert_or_update_file, info[:filename], info[:md5checksum], info[:size], info[:type], info[:state], current_timestamp, info[:deleted],
                 info[:thumbnail_filename], info[:thumbnail_md5checksum], info[:thumbnail_size])
    end
  end

  def remove_files(type)
    @db.transaction do |db|
      db.execute(WebQuery.remove_files, type)
    end
  end

  def delete_file(file)
    @db.transaction do |db|
      db.execute(WebQuery.delete_file, file)
    end
  end

  def remove_old_arch16n_cache_files
    @db.transaction do |db|
      db.execute(WebQuery.delete_old_arch16n_cache_files)
    end
  end

  # DATABASE HELPERS

  def current_version
    version = @db.get_first_value(WebQuery.get_current_version)
    version ||= '0'
    version
  end

  def latest_version
    version = @db.get_first_value(WebQuery.get_latest_version)
    version ||= '0'
    version
  end

  def add_version(userid)
    @db.transaction do |db|
      db.execute(WebQuery.insert_user_version, current_timestamp, userid)
      latest_version
    end
  end

  def insert_version(userid)
    @db.transaction do |db|
      db.execute(WebQuery.insert_version, current_timestamp, userid)
      latest_version
    end
  end

  def merge_database(fromDB, version)
    @db.execute_batch(WebQuery.merge_database(fromDB, version))
    validate_records
  end

  def validate_reln_value(db, relationshipid, relnvaluetimestamp, attributeid)
    return unless File.exists? @project_module.get_path(:validation_schema)

    begin
      db_validator = DatabaseValidator.new(self, @project_module.get_path(:validation_schema))

      result = db.execute(WebQuery.get_reln_value, relationshipid, relnvaluetimestamp, attributeid)
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
            update_reln_value_as_dirty(db, relationshipid, relnvaluetimestamp, userid, attributeid, vocabid, fields['freetext'], fields['certainty'], versionnum, 1, result)
          end
        rescue Exception => e
          @project_module.logger.error e
        end
      end
    rescue Exception => e
      @project_module.logger.error e
    end
  end

  def validate_aent_value(db, uuid, valuetimestamp, attributeid)
    return unless File.exists? @project_module.get_path(:validation_schema)

    begin
      db_validator = DatabaseValidator.new(self, @project_module.get_path(:validation_schema))

      result = db.execute(WebQuery.get_aent_value, uuid, valuetimestamp, attributeid)

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
            update_aent_value_as_dirty(db, uuid, valuetimestamp, userid, attributeid, vocabid, fields['measure'], fields['freetext'], fields['certainty'], versionnum, 1, result)
          end
        rescue Exception => e
          @project_module.logger.error e
        end
      end
    rescue Exception => e
      @project_module.logger.error e
    end
  end

  def validate_records(version = nil)
    @db.transaction do |db|
      version ||= current_version
      result = db.execute(WebQuery.get_all_aent_values_for_version, version)
      result.each do |row|
        validate_aent_value(db, row[0], row[1], row[2])
      end
      result = db.execute(WebQuery.get_all_reln_values_for_version, version)
      result.each do |row|
        validate_reln_value(db, row[0], row[1], row[2])
      end
      nil
    end
  end

  def create_app_database_from_version(toDB, version)
    if version.to_i == 0
      FileUtils.cp path, toDB
    else
      @db.execute_batch(WebQuery.create_sync_database_from_version(toDB, version))
    end
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

  def self.migrate_database(from, to)
    db = SpatialiteDB.new(to)
    content = File.read(Rails.root.join('lib', 'assets', 'migrate.sql'))
    content.gsub!('FAIMS_1_3.sqlite3', from)
    content.gsub!('FAIMS_2_0.sqlite3', to)
    db.execute_batch(content)
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

  def with_transaction
    @db.transaction do |db|
      yield db
    end
  end

  # TEST helpers
  def reorder_attributes(names)
    # this is used by automated tests and is hardcoded for the sync example
    names.each_with_index do |name, index|
      @db.execute("update idealAent set aentCountOrder = #{index + 1} where attributeid = (select attributeid from attributekey where attributename = '#{name}') and aenttypeid = (select aenttypeid from aenttype where aenttypename = 'small')")
    end
  end

  def get_entity_uuid(identifer)
    @db.get_first_value(WebQuery.get_entity_uuid, identifer)
  end

  def update_format_string(name, string)
    @db.execute(WebQuery.update_format_string, string, name)
  end

  def update_append_character_string(name, string)
    @db.execute(WebQuery.update_append_character_string, string, name)
  end

  private

  def self.generate_spatial_ref_list
    temp = Tempfile.new('db')
    db = SpatialiteDB.new(temp.path)
    db.execute("SELECT InitSpatialMetaData();")
    result = db.execute("select srid || ' / ' || ref_sys_name, auth_srid from spatial_ref_sys;")
    FileUtils.remove_entry_secure Rails.root.join('lib/assets/spatial_ref_list.json') if File.exists? Rails.root.join('lib/assets/spatial_ref_list.json')
    File.open(Rails.root.join('lib/assets/spatial_ref_list.json'), 'w') do |f|
      f.write(result.to_json)
    end
  end

  def self.generate_template_db
    FileUtils.remove_entry_secure Rails.root.join('lib/assets/template_db.sqlite3') if File.exists? Rails.root.join('lib/assets/template_db.sqlite3')
    db = SpatialiteDB.new(Rails.root.join('lib/assets/template_db.sqlite3').to_s)
    db.execute("SELECT InitSpatialMetaData();")
  end

  def clean(value)
    return nil if value.blank?
    value
  end

end