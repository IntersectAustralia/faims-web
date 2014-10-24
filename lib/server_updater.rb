class ServerUpdater

  class ServerUpdaterException < Exception
  end

  class << self

    def has_server_updates
      File.exists? faims_update_file
    end

    def check_server_available
      get_deployment_version
      true
    rescue Exception
      false
    end

    def check_server_updates
      raise ServerUpdaterException, 'Could not find internet connection to check for updates.' unless check_server_available

      request_json = get_deployment_version
      server_json = get_local_version

      has_updates = server_json['version'].to_f < request_json['version'].to_f
      if has_updates
        puts 'Found new updates.'
        FileUtils.touch faims_update_file
      else
        puts 'Everything is update to date.'
      end

      has_updates
    rescue ServerUpdaterException => e
      raise e
    rescue Exception => e
      Rails.logger.error e
      raise Exception, 'Encountered an unexpected error trying to check for updates.'
    end

    def update_server
      return unless check_server_updates

      puts 'Updating server... Please wait this could take a while.'

      status = run_update_script

      if status == 0
        puts 'No changes were made.'
      elsif status == 2
        puts 'Finished updating server.'
      else
        puts 'Encountered an error trying to update server.'
      end

      FileUtils.rm faims_update_file if File.exists? faims_update_file

      status
    end

    def get_deployment_version
      Rails.env == 'test' ? JSON.parse(File.read(faims_remote_deployment_file)) : JSON.parse(Net::HTTP.get(URI(faims_update_url)))
    end

    def get_local_version
      JSON.parse(File.read(faims_deployment_file))
    end

    def faims_update_url
      Rails.application.config.server_has_update_url
    end

    def faims_update_file
      Rails.env == 'test' ? Rails.root.join('tmp/.faims_has_updates') : Rails.application.config.server_has_update_file
    end

    def faims_remote_deployment_file
      Rails.env == 'test' ? Rails.root.join('tmp/.remote_deployment_version') : Rails.application.config.server_deployment_version_file
    end

    def faims_deployment_file
      Rails.env == 'test' ? Rails.root.join('tmp/.deployment_version') : Rails.application.config.server_deployment_version_file
    end

    def faims_run_update_script_file
      Rails.root.join('tmp/.run_update_script')
    end

    def run_update_script
      return File.read(faims_run_update_script_file).to_i if Rails.env == 'test' and File.exists? faims_run_update_script_file

      request_json = get_deployment_version

      # first run puppet script to update the repo
      system("sudo FACTER_app_tag=#{request_json['tag']} puppet apply --pluginsync #{Rails.root.join('puppet/repo.pp').to_s} --modulepath=#{Rails.root.join('puppet/modules').to_s}:$HOME/.puppet/modules --detailed-exitcodes >> #{Rails.root.join('log/puppet.log')}")

      # check if updating repo failed
      return $?.exitstatus if $?.exitstatus == 4 or $?.exitstatus == 6

      # then run puppet script to update the server
      system("sudo FACTER_app_tag=#{request_json['tag']} puppet apply --pluginsync #{Rails.root.join('puppet/site.pp').to_s} --modulepath=#{Rails.root.join('puppet/modules').to_s}:$HOME/.puppet/modules --detailed-exitcodes >> #{Rails.root.join('log/puppet.log')}")

      # return exit status
      $?.exitstatus
    end
  end

end