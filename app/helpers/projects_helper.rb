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
    @firstAttributeGroup = first_arch_ent.group_by{|a|a[3]}
    @secondAttributeGroup = second_arch_ent.group_by{|a|a[3]}
    attributeKeys = @firstAttributeGroup.keys | @secondAttributeGroup.keys
    @attributeKeys = {}
    @first_attributeInfos = {}
    @second_attributeInfos = {}
    attributeKeys.each do |attributeKey|
      first_info = project.db.get_arch_ent_attribute_info(first_uuid,@firstAttributeGroup[attributeKey][0][9],@firstAttributeGroup[attributeKey][0][1])
      @first_attributeInfos[attributeKey] = first_info[0][0]
      second_info = project.db.get_arch_ent_attribute_info(second_uuid,@secondAttributeGroup[attributeKey][0][9],@secondAttributeGroup[attributeKey][0][1])
      @second_attributeInfos[attributeKey] = second_info[0][0]
      if(@firstAttributeGroup[attributeKey].blank? || @secondAttributeGroup[attributeKey].blank?)
        @attributeKeys[attributeKey] = false
      else
        if(@firstAttributeGroup[attributeKey].length.eql?(@secondAttributeGroup[attributeKey].length))
          @firstAttributeGroup[attributeKey].length.times do |i|
            if(@firstAttributeGroup[attributeKey][i-1][4].eql?(@secondAttributeGroup[attributeKey][i-1][4]) &&
                @firstAttributeGroup[attributeKey][i-1][5].eql?(@secondAttributeGroup[attributeKey][i-1][5]) &&
                @firstAttributeGroup[attributeKey][i-1][6].eql?(@secondAttributeGroup[attributeKey][i-1][6]) &&
                @firstAttributeGroup[attributeKey][i-1][7].eql?(@secondAttributeGroup[attributeKey][i-1][7]))
              @attributeKeys[attributeKey] = true
            else
              @attributeKeys[attributeKey] = false
              break
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
    @firstAttributeGroup = first_reln.group_by{|a|a[3]}
    @secondAttributeGroup = second_reln.group_by{|a|a[3]}
    attributeKeys = @firstAttributeGroup.keys | @secondAttributeGroup.keys
    @attributeKeys = {}
    @first_attributeInfos = {}
    @second_attributeInfos = {}
    attributeKeys.each do |attributeKey|
      first_info = project.db.get_rel_attribute_info(first_rel_id,@firstAttributeGroup[attributeKey][0][9],@firstAttributeGroup[attributeKey][0][2])
      @first_attributeInfos[attributeKey] = first_info[0][0]
      second_info = project.db.get_rel_attribute_info(second_rel_id,@secondAttributeGroup[attributeKey][0][9],@secondAttributeGroup[attributeKey][0][2])
      @second_attributeInfos[attributeKey] = second_info[0][0]
      if(@firstAttributeGroup[attributeKey].blank? || @secondAttributeGroup[attributeKey].blank?)
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
              break
            end
          end
        else
          @attributeKeys[attributeKey] = false
        end
      end
    end
  end
end
