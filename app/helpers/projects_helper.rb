module ProjectsHelper
  def group_ids(ids)
    prev_id = ids[0][0]
    @id_array = []
    array = []
    for id in ids
      if prev_id != id[0]
        @id_array << array
        array = []
        prev_id = id[0]
      end
      array << id
    end
    @id_array << array
  end
  
  def get_files(attributes,type_index, value_index)
    contained_files = []
    counts = Hash.new(0)
    @files = {}
    for attribute in attributes
      if attribute[type_index].to_s.downcase.eql?("file")
        path = attribute[value_index]
        name = File.basename(path)[File.basename(path).to_s.index('_')+1..-1]
        contained_files.each do |contained_file|
          p contained_file
          counts[contained_file] += 1
        end
        if(contained_files.include?(name))
          file_name = File.basename(path,'.*')[File.basename(path,'*').to_s.index('_')+1..-1] + '(' + counts[name].to_s + ')' + File.extname(path)
        else
          file_name = name
        end
        @files[path] = file_name
        contained_files.push(name)
      end
    end
  end

  def compare_arch_entities(first_uuid,second_uuid,first_timestamp, second_timestamp, project)
    first_arch_ent = project.db.get_arch_entity_attributes(first_uuid)
    second_arch_ent = project.db.get_arch_entity_attributes(second_uuid)
    @firstInfo = project.db.get_arch_ent_info(first_uuid, first_timestamp)[0][0]
    @secondInfo = project.db.get_arch_ent_info(second_uuid, second_timestamp)[0][0]
    @firstAttributeValueGroup = project.db.get_arch_ent_attribute_for_comparison(first_uuid).group_by{|a|a[1]}
    @secondAttributeValueGroup = project.db.get_arch_ent_attribute_for_comparison(second_uuid).group_by{|a|a[1]}
    @firstAttributeGroup = first_arch_ent.group_by{|a|a[3]}
    @secondAttributeGroup = second_arch_ent.group_by{|a|a[3]}
    attributeKeys = @firstAttributeGroup.keys | @secondAttributeGroup.keys
    @attributeKeys = {}
    @first_attributeInfos = {}
    @second_attributeInfos = {}
    attributeKeys.each do |attributeKey|
      if(!@firstAttributeGroup[attributeKey].nil?)
        first_info = project.db.get_arch_ent_attribute_info(first_uuid,@firstAttributeGroup[attributeKey][0][9],@firstAttributeGroup[attributeKey][0][1])
        @first_attributeInfos[attributeKey] = first_info[0][0]
      end
      if(!@secondAttributeGroup[attributeKey].nil?)
        second_info = project.db.get_arch_ent_attribute_info(second_uuid,@secondAttributeGroup[attributeKey][0][9],@secondAttributeGroup[attributeKey][0][1])
        @second_attributeInfos[attributeKey] = second_info[0][0]
      end

      if(@firstAttributeGroup[attributeKey].nil? || @secondAttributeGroup[attributeKey].nil?)
        @attributeKeys[attributeKey] = false
      else
        if(@firstAttributeGroup[attributeKey].length.eql?(@secondAttributeGroup[attributeKey].length))
          @firstAttributeGroup[attributeKey].length.times do |i|
            if(@firstAttributeGroup[attributeKey][i-1][5].eql?(@secondAttributeGroup[attributeKey][i-1][5]) &&
                @firstAttributeGroup[attributeKey][i-1][5].eql?(@secondAttributeGroup[attributeKey][i-1][5]) &&
                @firstAttributeGroup[attributeKey][i-1][6].eql?(@secondAttributeGroup[attributeKey][i-1][6]) &&
                @firstAttributeGroup[attributeKey][i-1][7].eql?(@secondAttributeGroup[attributeKey][i-1][7]))
              @attributeKeys[attributeKey] = true
            else
              @attributeKeys[attributeKey] = false
            end
          end
        else
          @attributeKeys[attributeKey] = false
        end
      end
    end
  end

  def compare_relationships(first_rel_id,second_rel_id,first_timestamp, second_timestamp, project)
    first_reln = project.db.get_rel_attributes(first_rel_id)
    second_reln = project.db.get_rel_attributes(second_rel_id)
    @firstInfo = project.db.get_rel_info(first_rel_id, first_timestamp)[0][0]
    @secondInfo = project.db.get_rel_info(second_rel_id, second_timestamp)[0][0]
    @firstAttributeValueGroup = project.db.get_rel_attribute_for_comparison(first_rel_id).group_by{|a|a[2]}
    @secondAttributeValueGroup = project.db.get_rel_attribute_for_comparison(second_rel_id).group_by{|a|a[2]}
    @firstAttributeGroup = first_reln.group_by{|a|a[3]}
    @secondAttributeGroup = second_reln.group_by{|a|a[3]}
    attributeKeys = @firstAttributeGroup.keys | @secondAttributeGroup.keys
    @attributeKeys = {}
    @first_attributeInfos = {}
    @second_attributeInfos = {}
    attributeKeys.each do |attributeKey|
      if(!@firstAttributeGroup[attributeKey].nil?)
        first_info = project.db.get_rel_attribute_info(first_rel_id,@firstAttributeGroup[attributeKey][0][9],@firstAttributeGroup[attributeKey][0][2])
        @first_attributeInfos[attributeKey] = first_info[0][0]
      end
      if(!@secondAttributeGroup[attributeKey].nil?)
        second_info = project.db.get_rel_attribute_info(second_rel_id,@secondAttributeGroup[attributeKey][0][9],@secondAttributeGroup[attributeKey][0][2])
        @second_attributeInfos[attributeKey] = second_info[0][0]
      end
      if(@firstAttributeGroup[attributeKey].nil? || @secondAttributeGroup[attributeKey].nil?)
        @attributeKeys[attributeKey] = false
      else
        if(@firstAttributeGroup[attributeKey].length.eql?(@secondAttributeGroup[attributeKey].length))
          @firstAttributeGroup[attributeKey].length.times do |i|
            if(@firstAttributeGroup[attributeKey][i-1][4].eql?(@secondAttributeGroup[attributeKey][i-1][4]) &&
                @firstAttributeGroup[attributeKey][i-1][5].eql?(@secondAttributeGroup[attributeKey][i-1][5]) &&
                @firstAttributeGroup[attributeKey][i-1][6].eql?(@secondAttributeGroup[attributeKey][i-1][6]))
              @attributeKeys[attributeKey] = true
            else
              @attributeKeys[attributeKey] = false
            end
          end
        else
          @attributeKeys[attributeKey] = false
        end
      end
    end
  end

  def has_history_change(row_index, key)
    return true if row_index == @history_rows.size - 1
    c1 = @history_rows[@timestamps[row_index][1]][key]
    c2 = @history_rows[@timestamps[row_index + 1][1]][key]
    return c1[:value] != c2[:value] if c1[:attributeid]
    return (c1[:geospatial] != c2[:geospatial]) | (c1[:deleted] != c2[:deleted])
  end

  def show_arch_ent_attributes_history(project, timestamps)
    @history_rows = {}
    @history_keys = ['Geospatial']

    timestamps.each do |timestamp|
      attributes = project.db.get_arch_ent_attributes_at_timestamp(timestamp[0], timestamp[1])

      # history row data
      row = {}

      # cell data
      attributes.each do |attribute|

        # entity cell data
        cell = {
          uuid: attribute[0],
          attributeid: nil,
          timestamp: attribute[6],
          user: attribute[3],
          deleted: attribute[8],
          geospatial: attribute[4],
          userid: attribute[10],
          isforked: attribute[12]
        }
        row['Geospatial'] = cell

        # attribute cell data
        cell = {
          uuid: attribute[0],
          attributeid: attribute[2],
          timestamp: attribute[7],
          user: attribute[5],
          value: attribute[9],
          userid: attribute[11],
          isforked: attribute[13]
        }

        row[attribute[1]] = cell

        @history_keys.push(attribute[1]) unless @history_keys.include? attribute[1] # add key
      end

      @history_rows[timestamp[1]] = row
    end
  end

  def show_rel_attributes_history(project,timestamps)
    @history = {}
    @has_changes = {}
    @attribute_keys = ['timestamp','edited by']
    timestamps.each do |timestamp|
      attribute_history = {}
      attributes = project.db.get_rel_attributes_at_timestamp(timestamp[0],timestamp[1])

      entity_deleted = false
      attribute_history['timestamp'] = timestamp[1]
      attribute_history['edited by'] = attributes[0][4]

      attributes.each do |attribute|
        attribute_history[attribute[2]] = attribute[9]
        @attribute_keys.push(attribute[2])
        entity_deleted = attribute[8].nil? ? false : true
      end
      attribute_history['geospatial'] = attributes[0][3]
      attribute_history['deleted'] = entity_deleted
      @attribute_keys = @attribute_keys.uniq
      @history[timestamp[1]] = attribute_history
      changes = project.db.get_rel_attributes_changes_at_timestamp(timestamp[0],timestamp[1])
      attribute_changes = {}
      changes.each do |change|
        if change[1].eql?('RelationshipDeleted')
          if change[2].eql?('true')
            attribute_changes['deleted'] = true
          end
        elsif change[1].eql?('geospatialcolumn')
          attribute_changes['geospatial'] = true
        else
          attribute_changes[change[1]] = true
        end
      end
      @has_changes[timestamp[1]] = attribute_changes
    end
    @attribute_keys.push('geospatial')
    @attribute_keys.push('deleted')
  end
end
