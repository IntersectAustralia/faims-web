module XSDValidator

  require 'nokogiri'
  def self.validate_data_schema(file)
    validate_schema(File.expand_path("../assets/data_schema.xsd", __FILE__), file)
  end

  def self.validate_ui_schema(file)
    validate_schema(File.expand_path("../assets/ui_schema.xsd", __FILE__), file)
  end

  def self.validate_schema(xsd, file)
    xsd = Nokogiri::XML::Schema(File.read(xsd))
    doc = Nokogiri::XML(File.read(file))

    result = xsd.validate(doc).each do |error|
      error.message
    end

    result
  end

end