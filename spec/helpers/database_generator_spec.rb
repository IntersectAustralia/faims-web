require 'spec_helper'
require 'tempfile'
require 'sqlite3'

describe DatabaseGenerator do

  it "Generates and Parses database" do
    tempfile = Tempfile.new('db.sqlite3')
    DatabaseGenerator.generate_database(tempfile.path, Rails.root.join('spec', 'assets', 'data_schema.xml').to_s)
    db = SQLite3::Database.new(tempfile.path)
    db.enable_load_extension(true)
    db.execute("select load_extension('#{DatabaseGenerator.spatialite_library}')")
    result = db.execute("select count(*) || 'ideal arch ent' from idealAEnt union select count(*) || 'ideal reln'  from idealreln union select count(*) || 'aent type' from aenttype union select count(*) || 'relntype' from relntype union select count(*) || 'attributekey'  from attributekey;")
    result[0].should == ["2aent type"]
    result[1].should == ["30attributekey"]
    result[2].should == ["3ideal reln"]
    result[3].should == ["3relntype"]
    result[4].should == ["46ideal arch ent"]
    tempfile.unlink
  end

end
