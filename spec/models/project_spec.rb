require 'spec_helper'

describe Project do

  describe "Validations" do
    it { should_not allow_value("").for(:name) }

    it { should_not allow_value("Project \\").for(:name)}
    it { should_not allow_value("Project /").for(:name)}
    it { should_not allow_value("Project ?").for(:name)}
    it { should_not allow_value("Project %").for(:name)}
    it { should_not allow_value("Project *").for(:name)}
    it { should_not allow_value("Project :").for(:name)}
    it { should_not allow_value("Project |").for(:name)}
    it { should_not allow_value("Project \"").for(:name)}
    it { should_not allow_value("Project '").for(:name)}
    it { should_not allow_value("Project <").for(:name)}
    it { should_not allow_value("Project >").for(:name)}
    it { should_not allow_value("Project .").for(:name)}

    it { should allow_value("Project 1").for(:name)}
    it { should allow_value("Project Test 1").for(:name)}
    it { should allow_value("Project Test #1").for(:name)}
    it { should allow_value("Project Test @Something").for(:name)}

    it "project names should be unique" do
      p1 = FactoryGirl.build(:project, :name => "Project 1")
      p2 = FactoryGirl.build(:project, :name => "Project 2")
      p3 = FactoryGirl.build(:project, :name => "Project 1")
      p4 = FactoryGirl.build(:project, :name => "Project    1")
      p5 = FactoryGirl.build(:project, :name => "    Project 1    ")
      p1.save.should == true
      p2.save.should == true
      p3.save.should == false
      p4.save.should == false
      p5.save.should == false
    end
  end

  describe "Should order by name" do
    it do
      p1 = FactoryGirl.create(:project, :name => "B Project")
      p2 = FactoryGirl.create(:project, :name => "A Project")
      p3 = FactoryGirl.create(:project, :name => "C Project")
      projects = Project.all
      projects.should == [p2, p1, p3]
    end
  end

end
