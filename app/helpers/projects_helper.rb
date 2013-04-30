module ProjectsHelper
  def get_files(attributes,type_index, value_index)
    contained_files = []
    counts = Hash.new(0)
    @files = {}
    for attribute in attributes
      if attribute[type_index].to_s.downcase == "file"
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
end
