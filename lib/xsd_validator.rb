def validate_data_schema(file)
  validate_schema(File.expand_path("../assets/data_schema.xsd", __FILE__), file)
end

def validate_ui_schema(file)
  validate_schema(File.expand_path("../assets/data_schema.xsd", __FILE__), file)
end

def validate_schema(xsd, file)
  #schema = LibXML::XML::Schema.new(xsd)
  #document = LibXML::XML::Document.file(file)
  #result = document.validate_schema(schema) do |message, flag|
  #  p message
  #end
  return true
end