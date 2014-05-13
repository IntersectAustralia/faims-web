module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

      when /^the home\s?page$/
        '/'

      # User paths
      when /the login page/
        new_user_session_path

      when /the logout page/
        destroy_user_session_path

      when /the user profile page/
        users_profile_path

      when /the request account page/
        new_user_registration_path

      when /the edit my details page/
        edit_user_registration_path

      when /^the user details page for (.*)$/
        user_path(User.where(:email => $1).first)

      when /^the change password page for (.*)$/
        change_password_user_path(User.where(:email => $1).first)

      when /^the edit details page for (.*)$/
        edit_details_user_path(User.where(:email => $1).first)

      when /^the edit role page for (.*)$/
        edit_role_user_path(User.where(:email => $1).first)

      when /^the reset password page$/
        edit_user_password_path

      # Users paths
      when /the access requests page/
        access_requests_users_path

      when /the list users page/
        users_path

      when /^the add user page$/
        new_user_path

      # Project module paths
      when /the project modules page/
        project_modules_path

      when /the new project modules page/
        new_project_module_path

      when /the android project modules page/
        android_project_modules_path

      when /the android settings info for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_settings_info_path(project_module ? project_module.key : 'na')

      when /the android settings download "(.*)" link for (.*)$/
        project_module = ProjectModule.find_by_name($2)
        android_settings_download_path(project_module ? project_module.key : 'na', { request_file: $1 })

      when /the android db info for (.*) with request version (.*)$/
        project_module = ProjectModule.find_by_name($1)
        "/android/module/#{project_module ? project_module.key : 'na'}/db_info?version=#{$2}"

      when /the android download db link for (.*) with request version (.*)$/
        project_module = ProjectModule.find_by_name($1)
        "/android/module/#{project_module ? project_module.key : 'na'}/db_download?version=#{$2}"

      when /the android db info for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_project_module_db_info_path(project_module ? project_module.key : 'na')

      when /the android download db link for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_project_module_db_download_path(project_module ? project_module.key : 'na')

      when /the android server upload file link for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_server_file_upload_path(project_module ? project_module.key : 'na')

      when /the android app files info for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_app_file_info_path(project_module ? project_module.key : 'na')

      when /the android app files download link for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_app_file_download_path(project_module ? project_module.key : 'na')

      when /the android app upload file link for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_app_file_upload_path(project_module ? project_module.key : 'na')

      when /the android data file list for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_data_file_list_path(project_module ? project_module.key : 'na')

      when /the android data files info for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_data_file_info_path(project_module ? project_module.key : 'na')

      when /the android data files download link for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_data_file_download_path(project_module ? project_module.key : 'na')

      when /the android data upload file link for (.*)$/
        project_module = ProjectModule.find_by_name($1)
        android_data_file_upload_path(project_module ? project_module.key : 'na')

      when /upload data files page for (.*)/
        project_module = ProjectModule.find_by_name($1)
        project_module_file_list_path(project_module ? project_module.id : 'na')

# Add more mappings here.
# Here is an example that pulls values out of the Regexp:
#
#   when /^(.*)'s profile page$/i
#     user_profile_path(User.find_by_login($1))

      else
        begin
          page_name =~ /^the (.*) page$/
          path_components = $1.split(/\s+/)
          self.send(path_components.push('path').join('_').to_sym)
        rescue NoMethodError, ArgumentError
          raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                    "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)
