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
      p3.save.should == true
      p4.save.should == true
      p5.save.should == true
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
      p1 = FactoryGirl.create(:project, :name => "b Project")
      p2 = FactoryGirl.create(:project, :name => "a Project")
      p3 = FactoryGirl.create(:project, :name => "c Project")
      p4 = FactoryGirl.create(:project, :name => "B Project")
      p5 = FactoryGirl.create(:project, :name => "A Project")
      p6 = FactoryGirl.create(:project, :name => "C Project")
      projects = Project.all
      projects.should == [p2, p5, p1, p4, p3, p6]
    end
  end

  it "Archiving project" do
    begin
      project = make_project("Project 1")
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project.get_path(:project_archive)} -C #{tmp_dir}`
      entries = Dir.entries(tmp_dir + '/' + project.get_name(:project_dir))
      entries.include?(project.get_name(:db)).should be_true
      entries.include?(project.get_name(:ui_schema)).should be_true
      entries.include?(project.get_name(:ui_logic)).should be_true
      entries.include?(project.get_name(:settings)).should be_true
      entries.include?(project.get_name(:properties)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it "Packaging project" do
    begin
      project = make_project("Project 1")
      project.package_project_for
      tmp_dir = Dir.mktmpdir
      `tar jxf #{project.get_path(:package_archive)} -C #{tmp_dir}`
      entries = Dir.entries(tmp_dir+'/project')
      entries.include?(project.get_name(:db)).should be_true
      entries.include?(project.get_name(:ui_schema)).should be_true
      entries.include?(project.get_name(:ui_logic)).should be_true
      entries.include?(project.get_name(:settings)).should be_true
      entries.include?(project.get_name(:properties)).should be_true
      entries.include?('hash_sum').should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end

  end

  it "Archiving database" do
    begin
      project = make_project("Project 1")
      tmp_dir = Dir.mktmpdir
      `tar zxf #{project.get_path(:db_archive)} -C #{tmp_dir}`
      entries = Dir.entries(tmp_dir)
      entries.include?(project.get_name(:db)).should be_true
    rescue Exception => e
      raise e
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
    end
  end

  it "Creating project initialise directory" do
    project = make_project("Project 1")
    File.exists?(project.get_path(:project_dir)).should be_true
    File.exists?(project.get_path(:tmp_dir)).should be_true
    File.exists?(project.get_path(:server_files_dir)).should be_true
    File.exists?(project.get_path(:app_files_dir)).should be_true
  end

end
