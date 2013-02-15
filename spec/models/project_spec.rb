require 'spec_helper'
require File.expand_path("../../../features/support/projects", __FILE__)

describe Project do

  describe "Validations" do
    it { should_not allow_value("").for(:name) }

    it { should_not allow_value("Project \\").for(:name) }
    it { should_not allow_value("Project /").for(:name) }
    it { should_not allow_value("Project ?").for(:name) }
    it { should_not allow_value("Project %").for(:name) }
    it { should_not allow_value("Project *").for(:name) }
    it { should_not allow_value("Project :").for(:name) }
    it { should_not allow_value("Project |").for(:name) }
    it { should_not allow_value("Project \"").for(:name) }
    it { should_not allow_value("Project '").for(:name) }
    it { should_not allow_value("Project <").for(:name) }
    it { should_not allow_value("Project >").for(:name) }
    it { should_not allow_value("Project .").for(:name) }

    it { should allow_value("Project 1").for(:name) }
    it { should allow_value("Project Test 1").for(:name) }
    it { should allow_value("Project Test #1").for(:name) }
    it { should allow_value("Project Test @Something").for(:name) }

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

    it { should_not allow_value("").for(:key) }

    it "project keys should be unique" do
      uuid = SecureRandom.uuid
      p1 = FactoryGirl.build(:project, :key => uuid)
      p2 = FactoryGirl.build(:project, :key => uuid)
      p1.save.should == true
      p2.save.should == false
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

  it "Archiving project" do
    begin
      project = make_project("Project 1")
      tmp_dir = Dir.mktmpdir(project.dir_path)
      `tar zxf #{project.filepath} -C #{tmp_dir}`
      entries = Dir.entries(tmp_dir + '/' + project.dir_name)
      entries.include?(Project.db_name).should be_true
      entries.include?(Project.ui_schema_name).should be_true
      entries.include?(Project.ui_logic_name).should be_true
      entries.include?(Project.project_settings_name).should be_true
      entries.include?(Project.faims_properties_name).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it "Archiving database" do
    begin
      project = make_project("Project 1")
      tmp_dir = Dir.mktmpdir(project.dir_path)
      `tar zxf #{project.db_file_path} -C #{tmp_dir}`
      entries = Dir.entries(tmp_dir)
      entries.include?(Project.db_name).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

end
