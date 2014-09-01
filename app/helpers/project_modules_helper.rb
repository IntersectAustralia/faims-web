module ProjectModulesHelper
  
  def get_files(attributes, type_index, value_index)
    @files = {}
    for attribute in attributes
      if attribute[type_index].to_s.downcase.eql?("file")
        path = attribute[value_index]
        next unless path
        name = File.basename(path)[File.basename(path).to_s.index('_')+1..-1]
        @files[path] = name
      end
    end

    name_dup = {}
    @files.each do |path, name|
      count = name_dup[name] = name_dup[name] ? name_dup[name] + 1 : 0
      @files[path] = count == 0 ? name : duplicate_name(name, count)
    end
  end

  def duplicate_name(name, count)
    index = name.rindex('.')
    return name unless index
    name[0..index-1] + " (#{count})" + name[index..-1]
  end

  def compare_arch_entities(first_uuid, second_uuid, first_timestamp, second_timestamp, project_module)
    first_arch_ent = project_module.db.get_arch_entity_attributes(first_uuid)
    second_arch_ent = project_module.db.get_arch_entity_attributes(second_uuid)
    @firstInfo = project_module.db.get_arch_ent_info(first_uuid, first_timestamp)[0][0]
    @secondInfo = project_module.db.get_arch_ent_info(second_uuid, second_timestamp)[0][0]
    @firstAttributeValueGroup = project_module.db.get_arch_ent_attribute_for_comparison(first_uuid).group_by{|a|a[1]}
    @secondAttributeValueGroup = project_module.db.get_arch_ent_attribute_for_comparison(second_uuid).group_by{|a|a[1]}
    @firstAttributeGroup = first_arch_ent.group_by{|a|a[3]}
    @secondAttributeGroup = second_arch_ent.group_by{|a|a[3]}
    attributeKeys = @firstAttributeGroup.keys | @secondAttributeGroup.keys
    @attributeKeys = {}
    @first_attributeInfos = {}
    @second_attributeInfos = {}
    attributeKeys.each do |attributeKey|
      if @firstAttributeGroup[attributeKey] and @firstAttributeGroup[attributeKey][0][9] and @firstAttributeGroup[attributeKey][0][1]
        first_info = project_module.db.get_arch_ent_attribute_info(first_uuid,@firstAttributeGroup[attributeKey][0][9],@firstAttributeGroup[attributeKey][0][1])
        @first_attributeInfos[attributeKey] = first_info[0][0]
      end
      if @secondAttributeGroup[attributeKey] and @secondAttributeGroup[attributeKey][0][9] and @secondAttributeGroup[attributeKey][0][1]
        second_info = project_module.db.get_arch_ent_attribute_info(second_uuid,@secondAttributeGroup[attributeKey][0][9],@secondAttributeGroup[attributeKey][0][1])
        @second_attributeInfos[attributeKey] = second_info[0][0]
      end

      if @firstAttributeGroup[attributeKey].nil? || @secondAttributeGroup[attributeKey].nil?
        @attributeKeys[attributeKey] = false
      else
        if @firstAttributeGroup[attributeKey].length.eql?(@secondAttributeGroup[attributeKey].length)
          @firstAttributeGroup[attributeKey].length.times do |i|
            if @firstAttributeGroup[attributeKey][i-1][4].eql?(@secondAttributeGroup[attributeKey][i-1][4]) &&
                @firstAttributeGroup[attributeKey][i-1][5].eql?(@secondAttributeGroup[attributeKey][i-1][5]) &&
                @firstAttributeGroup[attributeKey][i-1][6].eql?(@secondAttributeGroup[attributeKey][i-1][6]) &&
                @firstAttributeGroup[attributeKey][i-1][7].eql?(@secondAttributeGroup[attributeKey][i-1][7])
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

  def compare_relationships(first_rel_id,second_rel_id,first_timestamp, second_timestamp, project_module)
    first_reln = project_module.db.get_rel_attributes(first_rel_id)
    second_reln = project_module.db.get_rel_attributes(second_rel_id)
    @firstInfo = project_module.db.get_rel_info(first_rel_id, first_timestamp)[0][0]
    @secondInfo = project_module.db.get_rel_info(second_rel_id, second_timestamp)[0][0]
    @firstAttributeValueGroup = project_module.db.get_rel_attribute_for_comparison(first_rel_id).group_by{|a|a[2]}
    @secondAttributeValueGroup = project_module.db.get_rel_attribute_for_comparison(second_rel_id).group_by{|a|a[2]}
    @firstAttributeGroup = first_reln.group_by{|a|a[3]}
    @secondAttributeGroup = second_reln.group_by{|a|a[3]}
    attributeKeys = @firstAttributeGroup.keys | @secondAttributeGroup.keys
    @attributeKeys = {}
    @first_attributeInfos = {}
    @second_attributeInfos = {}
    attributeKeys.each do |attributeKey|
      if(!@firstAttributeGroup[attributeKey].nil?)
        first_info = project_module.db.get_rel_attribute_info(first_rel_id,@firstAttributeGroup[attributeKey][0][9],@firstAttributeGroup[attributeKey][0][2])
        @first_attributeInfos[attributeKey] = first_info[0][0]
      end
      if(!@secondAttributeGroup[attributeKey].nil?)
        second_info = project_module.db.get_rel_attribute_info(second_rel_id,@secondAttributeGroup[attributeKey][0][9],@secondAttributeGroup[attributeKey][0][2])
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
    return true if c1 == nil or c2 == nil
    return c1[:value] != c2[:value] if c1[:attributeid]
    return (c1[:geospatial] != c2[:geospatial]) | (c1[:deleted] != c2[:deleted])
  end

  def show_arch_ent_attributes_history(project_module, timestamps)
    @history_rows = {}
    @history_keys = []

    timestamps.each do |timestamp|
      attributes = project_module.db.get_arch_ent_attributes_at_timestamp(timestamp[0], timestamp[1])

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
        row['Geometry'] = cell

        # attribute cell data
        cell = {
          uuid: attribute[0],
          attributeid: attribute[2],
          timestamp: attribute[7],
          user: attribute[5],
          value: attribute[9],
          userid: attribute[11],
          isforked: attribute[13],
          deleted: attribute[14]
        }

        row[attribute[1]] = cell

        @history_keys.push(attribute[1]) unless @history_keys.include? attribute[1] # add key
      end

      @history_rows[timestamp[1]] = row
    end

    @history_keys << 'Geometry'
  end

  def show_rel_attributes_history(project_module,timestamps)
    @history_rows = {}
    @history_keys = []

    timestamps.each do |timestamp|
      attributes = project_module.db.get_rel_attributes_at_timestamp(timestamp[0], timestamp[1])

      # history row data
      row = {}

      # cell data
      attributes.each do |attribute|

        # rel cell data
        cell = {
            relationshipid: attribute[0],
            attributeid: nil,
            timestamp: attribute[6],
            user: attribute[4],
            deleted: attribute[8],
            geospatial: attribute[3],
            userid: attribute[10],
            isforked: attribute[12]
        }
        row['Geometry'] = cell

        # attribute cell data
        cell = {
            relationshipid: attribute[0],
            attributeid: attribute[1],
            timestamp: attribute[7],
            user: attribute[5],
            value: attribute[9],
            userid: attribute[11],
            isforked: attribute[13],
            deleted: attribute[14]
        }

        row[attribute[2]] = cell

        @history_keys.push(attribute[2]) unless @history_keys.include? attribute[2] # add key
      end

      @history_rows[timestamp[1]] = row
    end

    @history_keys << 'Geometry'
  end

  def vocab_breadcrumb(vocab, id_to_vocab)
    name = vocab[0]
    parent = vocab[2]
    return name if parent.blank?
    return vocab_breadcrumb(id_to_vocab[parent], id_to_vocab) + " > #{name}"
  end

  def vocab_name_to_breadcrumb(vocabs)
    id_to_vocab = {}

    vocabs.each do |vocab|
      id_to_vocab[vocab[1]] = vocab
    end

    vocabs = vocabs.map do |vocab|
      [vocab_breadcrumb(vocab, id_to_vocab), vocab[1]]
    end

    vocabs.sort
  end

  def group_vocabularies(vocabs)
    map = {}

    vocabs.each do |v|
      if v[:vocab_id].blank?
        map[v[:temp_id]] = v
      else
        map[v[:vocab_id]] = v
      end

    end

    @grouped_vocabs = {}

    vocabs.each do |v|
      parent_vocab_id = v[:parent_vocab_id]
      parent_temp_id = v[:parent_temp_id]
      if parent_vocab_id == nil || !map.has_key?(parent_vocab_id)
        if parent_temp_id.blank? || !map.has_key?(parent_temp_id)
          (@grouped_vocabs[nil] ||= []) << v
        else
          (@grouped_vocabs[parent_temp_id] ||= []) << v
        end
      else
        (@grouped_vocabs[parent_vocab_id] ||= []) << v
      end
    end
  end

end
