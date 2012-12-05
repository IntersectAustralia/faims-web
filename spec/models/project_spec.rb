require 'spec_helper'

describe Project do

  describe "Validations" do
    it { should_not allow_value("").for(:name) }

    it "project names should be unique" do
      t1 = FactoryGirl.build(:project, :name => "Project 1")
      t2 = FactoryGirl.build(:project, :name => "Project 2")
      t3 = FactoryGirl.build(:project, :name => "Project 1")
      t1.save.should == true
      t2.save.should == true
      t3.save.should == false
    end
  end
end
