require 'spec_helper'

describe SecurityHelper do

  it 'should allow paths' do
    # check for root path and directory traversal
    lambda { SecurityHelper.sanitize_file_path('/tmp/something') }.should_not raise_error
    lambda { SecurityHelper.sanitize_file_path(Rails.root.to_s + 'modules') }.should_not raise_error
    # check for directory traversal only
    lambda { SecurityHelper.sanitize_relative_file_path('/tmp/something') }.should_not raise_error
    lambda { SecurityHelper.sanitize_relative_file_path(Rails.root.to_s + 'modules') }.should_not raise_error
    lambda { SecurityHelper.sanitize_relative_file_path('/etc/something') }.should_not raise_error
    lambda { SecurityHelper.sanitize_relative_file_path('tmp') }.should_not raise_error
  end

  it 'should not allow paths' do
    # check for root path and directory traversal
    lambda { SecurityHelper.sanitize_file_path('/etc/something') }.should raise_error
    lambda { SecurityHelper.sanitize_file_path(Rails.root.to_s + '../../etc/something') }.should raise_error
    lambda { SecurityHelper.sanitize_file_path(Rails.root.to_s + '%2e%2e/%2e%2e/etc/something') }.should raise_error
    # check for directory traversal only
    lambda { SecurityHelper.sanitize_relative_file_path(Rails.root.to_s + '../../etc/something') }.should raise_error
    lambda { SecurityHelper.sanitize_relative_file_path(Rails.root.to_s + '%2e%2e/%2e%2e/etc/something') }.should raise_error
  end

end