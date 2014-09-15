require 'spec_helper'

describe XSDValidator do

  def validate_data_schema(name)
    XSDValidator.validate_data_schema Rails.root.join('spec', 'assets', name).to_s
  end

  def validate_ui_schema(name)
    XSDValidator.validate_ui_schema Rails.root.join('spec', 'assets', name).to_s
  end

  def validate_validation_schema(name)
    XSDValidator.validate_validation_schema Rails.root.join('spec', 'assets', name).to_s
  end

  describe "Validate Validation Schemas" do
    it { validate_validation_schema('validation_schema.xml').should be_empty }
    it { validate_validation_schema('validation_schema_error1.xml').should_not be_empty }
  end

  describe "Validate Data Schemas" do
    # normal test case
    it { validate_data_schema('data_schema.xml').should be_empty }
    # adding description to property of arch entity
    it { validate_data_schema('data_schema_2.xml').should be_empty }
    # empty data
    it { validate_data_schema('data_schema_3.xml').should be_empty }
    # adding description to attribute and vocab
    it { validate_data_schema('data_schema_4.xml').should be_empty }
    # adding hierarchical vocabs and descriptions
    it { validate_data_schema('data_schema_5.xml').should be_empty }
    # adding file and thumbnails
    it { validate_data_schema('data_schema_6.xml').should be_empty }
    # error
    it { validate_data_schema('data_schema_error1.xml').should_not be_empty }
  end

  describe "Validate UI Schemas" do
    # normal test case
    it { validate_ui_schema('ui_schema_1.xml').should be_empty }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_2.xml').should raise_error }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_3.xml').should raise_error }
    # no tab set
    it { validate_ui_schema('ui_schema_4.xml').should be_empty }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_5.xml').should raise_error }
    # incorrect binding path
    it { validate_ui_schema('ui_schema_6.xml').should be_empty }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_7.xml').should raise_error }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_8.xml').should raise_error }
    # missing group label
    it { validate_ui_schema('ui_schema_9.xml').should_not be_empty }
    # blank file
    it { validate_ui_schema('ui_schema_10.xml').should_not be_empty }
    # no content
    it { validate_ui_schema('ui_schema_11.xml').should_not be_empty }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_12.xml').should raise_error }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_13.xml').should raise_error }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_14.xml').should raise_error }
    # wrong image type
    it { validate_ui_schema('ui_schema_15.xml').should be_empty }
    # wrong reference for input
    it { validate_ui_schema('ui_schema_16.xml').should be_empty }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_17.xml').should raise_error }
    # ??? looks the same as 16 but with correct reference
    it { validate_ui_schema('ui_schema_18.xml').should be_empty }
    # invalid xml
    lambda { validate_ui_schema('ui_schema_19.xml').should raise_error }
    # long name
    it { validate_ui_schema('ui_schema_20.xml').should be_empty }
    # unescaped characters
    lambda { validate_ui_schema('ui_schema_21.xml').should raise_error }
    # accented characters
    it { validate_ui_schema('ui_schema_22.xml').should be_empty }
    # ui schema logic example
    it { validate_ui_schema('ui_schema_23.xml').should be_empty }
    # hidden attribute to tabs
    it { validate_ui_schema('ui_schema_24.xml').should be_empty }
    # scrollable attribute to tabs
    it { validate_ui_schema('ui_schema_25.xml').should be_empty }
    # latest example
    it { validate_ui_schema('ui_schema_26.xml').should be_empty }
    # map
    it { validate_ui_schema('ui_schema_27.xml').should be_empty }
    # sync attribute
    it { validate_ui_schema('ui_schema_28.xml').should be_empty }
    # error
    it { validate_ui_schema('ui_schema_error1.xml').should_not be_empty }
  end

end
