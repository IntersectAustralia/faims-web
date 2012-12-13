module XSLTParser

  require 'nokogiri'

  def self.parse_data_schema(file)
    xslt  = Nokogiri::XSLT(File.read(File.expand_path("../assets/data_schema.xsl", __FILE__)))
    doc = Nokogiri::XML(File.read(file))

    result = xslt.transform(doc).text

    result
  end

end