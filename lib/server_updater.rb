class ServerUpdater

  class ServerUpdaterException < Exception
  end

  class << self

    def has_server_updates
      File.exists? Rails.application.config.server_has_update_file
    end

    def check_server_available
      get_deployment_version
      true
    rescue Exception
      false
    end

    def check_server_updates
      raise ServerUpdaterException, 'Could not find internet connection to check for updates' unless check_server_available

      request_json = get_deployment_version
      server_json = get_local_version

      has_updates = server_json['version'].to_f < request_json['version'].to_f
      if has_updates
        puts 'Found new updates'
        FileUtils.touch Rails.application.config.server_has_update_file
      else
        puts 'Everything is update to date'
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

      puts 'Updating server... Please wait this could take a while'

      status = run_update_script

      if status == 0
        puts 'No changes were made'
      elsif status == 2
        puts 'Finished updating server'
      else
        puts 'Encountered an error trying to update server'
      end

      FileUtils.rm Rails.application.config.server_has_update_file if File.exists? Rails.application.config.server_has_update_file

      status
    end

    def get_deployment_version
      JSON.parse(Net::HTTP.get(URI(Rails.application.config.server_has_update_url)))
    end

    def get_local_version
      JSON.parse(File.read(Rails.application.config.server_deployment_version_file))
    end

    def run_update_script
      request_json = get_deployment_version

      system("sudo FACTER_app_tag=#{request_json['tag']} puppet apply --pluginsync #{Rails.root.join('puppet/site.pp').to_s} --modulepath=#{Rails.root.join('puppet/modules').to_s}:$HOME/.puppet/modules --detailed-exitcodes")

      $?.exitstatus
    end
  end

end