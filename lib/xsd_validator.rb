module XSDValidator

  require 'nokogiri'

  def self.validate_data_schema(file)
    validate_schema(File.expand_path("../assets/data_schema.xsd", __FILE__), file)
  end

  def self.validate_ui_schema(file)
    validate_schema(File.expand_path("../assets/ui_schema.xsd", __FILE__), file)
  end

  def self.validate_validation_schema(file)
    validate_schema(File.expand_path("../assets/validation_schema.xsd", __FILE__), file)
  end

  def self.validate_schema(xsd, file)
  begin
      xsd = Nokogiri::XML::Schema(File.read(xsd))
      doc = Nokogiri::XML(File.read(file)) { |config| config.strict }

      result = []
      xsd.validate(doc).each do |error|
        result.push(error)
      end

      result
    rescue Nokogiri::XML::SyntaxError => e
      raise e
    end
  end

end