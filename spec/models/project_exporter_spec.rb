require 'spec_helper'
require Rails.root.join('features/support/project_exporters')

describe ProjectExporter do

  def raise_exporter_exception(message)
    raise_error(ProjectExporter::ProjectExporterException, message)
  end

  describe 'Validations' do

    it 'should check if config exists' do
      tarball = make_exporter_tarball('Exporter 1', nil, skip_config: true)
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.valid?
      exporter.errors.messages[:config].should == ['Cannot find config']
    end

    it 'should check if exporter name exists' do
      tarball = make_exporter_tarball('Exporter 1', {version:0})
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.valid?
      exporter.errors.messages[:config].should == ['Config is missing exporter name']
    end

    it 'should check if exporter version exists' do
      tarball = make_exporter_tarball('Exporter 1', {name:"Exporter 1"})
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.valid?
      exporter.errors.messages[:config].should == ['Config is missing exporter version']
    end

    it 'should check if install script exists' do
      tarball = make_exporter_tarball('Exporter 1', nil, skip_installer: true)
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.valid?
      exporter.errors.messages[:install_script].should == ['Cannot find install script']
    end

    it 'should check if uninstall script exists' do
      tarball = make_exporter_tarball('Exporter 1', nil, skip_uninstaller: true)
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.valid?
      exporter.errors.messages[:uninstall_script].should == ['Cannot find uninstall script']
    end

    it 'should check if export script exists' do
      tarball = make_exporter_tarball('Exporter 1', nil, skip_exporter: true)
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.valid?
      exporter.errors.messages[:export_script].should == ['Cannot find export script']
    end

  end

  describe 'Extract' do

    it 'should extract tarball' do
      tarball = make_exporter_tarball('Exporter 1')
      ProjectExporter.extract_exporter(tarball).should_not be_nil
    end

    it 'should raise exception if tarball cannot be extracted' do
      tarball = Rails.root.join('features/assets/db.sqlite3').to_s
      lambda { ProjectExporter.extract_exporter(tarball) }.should raise_exporter_exception('Cannot extract archive')
    end

    it 'should raise exception if tarball is missing directory' do
      tarball = Rails.root.join('features/assets/empty.tar.gz').to_s
      lambda { ProjectExporter.extract_exporter(tarball) }.should raise_exporter_exception('Cannot find directory in archive')
    end

  end

  describe 'Finders' do

    after(:each) do
      FileUtils.rm_rf Dir["#{ProjectExporter.exporters_dir}/*"]
    end

    it 'should find all' do
      (1..3).each do |i|
        tarball = make_exporter_tarball("Exporter #{i}")
        dir = ProjectExporter.extract_exporter(tarball)
        FileUtils.mv dir, ProjectExporter.exporters_dir
      end

      ProjectExporter.all.size.should == 3
    end

    it 'should find by name' do
      tarball = make_exporter_tarball('Exporter 1')
      dir = ProjectExporter.extract_exporter(tarball)
      FileUtils.mv dir, ProjectExporter.exporters_dir

      exporter = ProjectExporter.find_by_name('Exporter 1')
      exporter.name.should == 'Exporter 1'
    end

  end

  describe 'Installer' do

    after(:each) do
      FileUtils.rm_rf Dir["#{ProjectExporter.exporters_dir}/*"]
    end
    
    it 'should install exporter' do
      tarball = make_exporter_tarball('Exporter 1')
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install.should be_true
      ProjectExporter.find_by_name('Exporter 1').should_not be_nil
    end

    it 'should return false if installer fails' do
      tarball = make_exporter_tarball('Exporter 1', nil, install_script: 'install_fail.sh')
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install.should be_false
      ProjectExporter.find_by_name('Exporter 1').should be_nil
    end

    it 'should re-install exporter is updated' do
      tarball = make_exporter_tarball('Exporter 1', {name: 'Exporter 1', version: 1})
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install.should be_true
      exporter = ProjectExporter.find_by_name('Exporter 1')
      exporter.version.should == 1

      tarball = make_exporter_tarball('Exporter 1', {name: 'Exporter 1', version: 2})
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install.should be_true
      exporter = ProjectExporter.find_by_name('Exporter 1')
      exporter.version.should == 2
    end

    it 'should raise exception if installer is missing' do
      tarball = make_exporter_tarball('Exporter 1', nil, skip_installer: true)
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      lambda { exporter.install }.should raise_exporter_exception("Exporter doesn't contain install.sh script")
    end

    it 'should raise exception if exporter already exists' do
      tarball = make_exporter_tarball('Exporter 1', {name: 'Exporter 1', version: 1})
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install.should be_true
      ProjectExporter.find_by_name('Exporter 1').should_not be_nil

      tarball = make_exporter_tarball('Exporter 1', {name: 'Exporter 1', version: 1})
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      lambda { exporter.install }.should raise_exporter_exception("Exporter 'Exporter 1' already exists with version '1'")
    end

  end

  describe 'Uninstaller' do

    after(:each) do
      FileUtils.rm_rf Dir["#{ProjectExporter.exporters_dir}/*"]
    end

    it 'should uninstall' do
      tarball = make_exporter_tarball('Exporter 1')
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install

      exporter = ProjectExporter.find_by_name('Exporter 1')
      exporter.uninstall.should be_true

      ProjectExporter.find_by_name('Exporter 1').should be_nil
    end

    it 'should return false if uninstall fails' do
      tarball = make_exporter_tarball('Exporter 1', nil, uninstall_script: 'uninstall_fail.sh')
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install

      exporter = ProjectExporter.find_by_name('Exporter 1')
      exporter.uninstall.should be_false

      ProjectExporter.find_by_name('Exporter 1').should_not be_nil
    end

    it 'should raise exception if uninstaller is missing' do
      tarball = make_exporter_tarball('Exporter 1', nil, skip_uninstaller: true)
      dir = ProjectExporter.extract_exporter(tarball)
      exporter = ProjectExporter.new(dir)
      exporter.install

      lambda { exporter.uninstall }.should raise_exporter_exception("Exporter doesn't contain uninstall.sh script")
    end

  end

  describe 'Export' do

    after(:each) do
      FileUtils.rm_rf Dir["#{ProjectExporter.exporters_dir}/*"]
    end

    it 'should export module' do

    end

    it 'should export module and return markup' do

    end

    it 'should export module and return file' do

    end

    it 'should return false if export fails' do

    end

    it 'should raise exception if export script is missing' do

    end

  end

end