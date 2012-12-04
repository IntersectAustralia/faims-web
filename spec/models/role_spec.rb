require 'spec_helper'

describe Role do
  describe "Associations" do
    it { should have_and_belong_to_many(:permissions) }
    it { should have_many(:users) }
  end
  
  describe "Scopes" do
    describe "By name" do
      it "should order the roles by name and include all roles" do
        r1 = Role.create(:name => "bcd")
        r2 = Role.create(:name => "aaa")
        r3 = Role.create(:name => "abc")
        Role.by_name.should eq([r2, r3, r1])
      end
    end
  end
    
  describe "Validations" do
    it { should validate_presence_of(:name) }

    it "should reject duplicate names" do
      attr = {:name => "abc"}
      Role.create!(attr)
      with_duplicate_name = Role.new(attr)
      with_duplicate_name.should_not be_valid
    end

    it "should reject duplicate names identical except for case" do
      Role.create!(:name => "ABC")
      with_duplicate_name = Role.new(:name => "abc")
      with_duplicate_name.should_not be_valid
    end
  end

end
