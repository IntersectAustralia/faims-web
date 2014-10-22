class ServerUpdater

  class ServerUpdaterException < Exception
  end

  class << self

    def has_server_updates
      File.exists? Rails.application.config.server_has_update_file
    end

    def check_server_available
      Net::HTTP.get(URI(Rails.application.config.server_has_update_url))
      true
    rescue Exception
      false
    end

    def check_server_updates
      raise ServerUpdaterException, 'Could not find internet connection to check for updates' unless check_server_available

      request_json = JSON.parse(Net::HTTP.get(URI(Rails.application.config.server_has_update_url)))
      server_json = JSON.parse(File.read(Rails.application.config.server_deployment_version_file))

      has_updates = server_json['version'].to_i < request_json['version'].to_i
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

      puts 'Please wait this could take a while ...'

      request_json = JSON.parse(Net::HTTP.get(URI(Rails.application.config.server_has_update_url)))

      system("sudo FACTER_app_tag=#{request_json['tag']} puppet apply --pluginsync #{Rails.root.join('puppet/site.pp').to_s} --modulepath=#{Rails.root.join('puppet/modules').to_s}:$HOME/.puppet/modules --detailed-exitcodes")

      result = nil
      if $?.exitstatus == 0
        puts 'No changes were made'
        result = true
      elsif $?.exitstatus == 2
        puts 'Finished updating server'
        result = true
      else
        puts 'Encountered an error trying to update server'
      end

      FileUtils.rm Rails.application.config.server_has_update_file if File.exists? Rails.application.config.server_has_update_file

      result
    end
  end

end