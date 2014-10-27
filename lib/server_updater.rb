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

        # create update file
        FileUtils.touch faims_update_file
      else
        puts 'Everything is update to date.'
      end

      has_updates
    rescue ServerUpdaterException => e
      raise e
    rescue Exception => e
      Rails.logger.error e
      raise Exception, 'Encountered an unexpected error trying to check for updates. Please contact a system administrator to resolve this problem.'
    end

    def update_server
      return if File.exists? faims_update_lock or !check_server_updates

      # create lock file
      FileUtils.touch faims_update_lock

      puts 'Updating server... Please wait this could take a while.'
      status = run_update_script

      if status == 0 or status == 2
        puts 'Finished updating server.'

        # cleanup update file
        FileUtils.rm faims_update_file if File.exists? faims_update_file
      else
        puts 'The server failed to update properly. Please contact a system administrator to resolve this problem.'
      end

      # cleanup lock file
      FileUtils.rm faims_update_lock if File.exists? faims_update_lock

      status
    end

    def restart_server
      return if File.exists? faims_update_lock

      puts 'Restarting server... Please wait this could take a while.'
      run_restart_script
    end

    def run_update_script
      request_json = get_deployment_version

      # update repo
      #system("sudo FACTER_app_tag=#{request_json['tag']} puppet apply --pluginsync #{Rails.root.join('puppet/repo.pp').to_s} --modulepath=#{Rails.root.join('puppet/modules').to_s}:$HOME/.puppet/modules --detailed-exitcodes >> #{Rails.root.join('log/puppet.log')}")
      #return $?.exitstatus if $?.exitstatus == 4 or $?.exitstatus == 6

      # update server
      system("sudo FACTER_app_tag=#{request_json['tag']} puppet apply --pluginsync #{Rails.root.join('puppet/update.pp').to_s} --modulepath=#{Rails.root.join('puppet/modules').to_s}:$HOME/.puppet/modules --detailed-exitcodes >> #{Rails.root.join('log/puppet.log')}")
      $?.exitstatus
    end

    def run_restart_script
      system("sudo puppet apply --pluginsync #{Rails.root.join('puppet/restart.pp').to_s} --modulepath=#{Rails.root.join('puppet/modules').to_s}:$HOME/.puppet/modules --detailed-exitcodes >> #{Rails.root.join('log/puppet.log')} &")
    end

    def get_deployment_version
      JSON.parse(Net::HTTP.get(URI(faims_update_url)))
    end

    def get_local_version
      JSON.parse(File.read(faims_deployment_file))
    end

    def faims_update_url
      Rails.application.config.server_has_update_url
    end

    def faims_update_file
      Rails.application.config.server_has_update_file
    end

    def faims_deployment_file
      Rails.application.config.server_deployment_version_file
    end

    def faims_update_lock
      Rails.env == 'test' ? Rails.root.join('tmp/.update_lock') : Rails.root.join('.update_lock')
    end

  end

end