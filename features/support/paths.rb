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

      when /^the edit role page for (.*)$/
        edit_role_user_path(User.where(:email => $1).first)

      when /^the reset password page$/
        edit_user_password_path

      # Users paths
      when /the access requests page/
        access_requests_users_path

      when /the list users page/
        users_path

      # Projects paths
      when /the projects page/
        projects_path

      when /the new projects page/
        new_project_path

      when /the android projects page/
        android_projects_path

      when /the android archive page for (.*)$/
        project = Project.find_by_name($1)
        android_project_archive_path(project ? project.key : "na")

      when /the android download link for (.*)$/
        project = Project.find_by_name($1)
        android_project_download_path(project ? project.key : "na")

      when /the android archive db page for "([^"]*)" with request version (.*)$/
        project = Project.find_by_name($1)
        "/android/project/#{project ? project.key : "na"}/archive_db?version=#{$2}"

      when /the android download db link for "([^"]*)" with request version (.*)$/
        project = Project.find_by_name($1)
        "/android/project/#{project ? project.key : "na"}/download_db?version=#{$2}"

      when /the android archive db page for (.*)$/
        project = Project.find_by_name($1)
        android_project_archive_db_path(project ? project.key : "na")

      when /the android download db link for (.*)$/
        project = Project.find_by_name($1)
        android_project_download_db_path(project ? project.key : "na")

      when /the android server file list page for (.*)$/
        project = Project.find_by_name($1)
        server_file_list_path(project ? project.key : "na")

      when /the android app file list page for (.*)$/
        project = Project.find_by_name($1)
        app_file_list_path(project ? project.key : "na")

      when /the android server files archive page for (.*)$/
        project = Project.find_by_name($1)
        server_file_archive_path(project ? project.key : "na")

      when /the android app files archive page for (.*)$/
        project = Project.find_by_name($1)
        app_file_archive_path(project ? project.key : "na")

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
