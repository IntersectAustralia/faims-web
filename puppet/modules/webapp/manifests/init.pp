class webapp {
  require common
  require sudo_user
  require apache
  require ruby
  require spatialite
  require imagemagick

  $webapp_user = hiera("webapp_user")
  $webapp_version = hiera("webapp_version")
  $ruby_version = hiera("ruby_version")
  $app_root = hiera("app_root")
  $exec_path = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
  $rbenv_root = "/home/${webapp_user}/.rbenv"
  $rbenv_path = "${rbenv_root}/bin:${exec_path}"
  $rbenv_env = "RBENV_ROOT=${rbenv_root}"

  exec { "install bundler gem":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "su - ${webapp_user} -c \"gem install bundler\"",
    unless      => "su - ${webapp_user} -c \"gem list bundler -i\"",
    logoutput   => "on_failure"
  }

  exec { "install webapp gems":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "su - ${webapp_user} -c \"cd ${app_root} && bundle install\"",
    unless      => "su - ${webapp_user} -c \"cd ${app_root} && bundle check\"",
    logoutput   => "on_failure",
    timeout     => 1800,
    require     => Exec["install bundler gem"]
  }

  exec { "initialise app":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "su - ${webapp_user} -c \"cd ${app_root} && bundle exec rake db:create db:migrate db:seed app:generate_secret modules:setup modules:clear\"",
    unless      => "su - ${webapp_user} -c \"cd ${app_root} && test -d modules\"",
    logoutput   => "on_failure",
    timeout     => 1800,
    require     => Exec["install webapp gems"]
  }

  exec { "update app":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "su - ${webapp_user} -c \"cd ${app_root} && bundle exec rake db:migrate assets:precompile\"",
    logoutput   => "on_failure",
    timeout     => 600,
    require     => Exec["initialise app"]
  }

  exec { "install passenger gem":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "su - ${webapp_user} -c \"gem install passenger\"",
    unless      => "su - ${webapp_user} -c \"gem list passenger -i\"",
    logoutput   => "on_failure",
    timeout     => 600
  }

  exec { "link passenger gem":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "ln -s `su - ${webapp_user} -c \"passenger-config --root\"` /etc/apache2/passenger",
    unless      => "test -d /etc/apache2/passenger",
    logoutput   => "on_failure",
    require     => Exec["install passenger gem"]
  }

  exec { "install passenger module":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "su - ${webapp_user} -c \"passenger-install-apache2-module --auto\"",
    unless      => "test -f /etc/apache2/passenger/buildout/apache2/mod_passenger.so",
    logoutput   => "on_failure",
    require     => Exec["link passenger gem"],
    timeout     => 1800
  }

  file { "/etc/apache2/conf-enabled/faims.conf":
    mode    => "0644",
    owner   => $webapp_user,
    group   => $webapp_user,
    content => template("webapp/faims.conf"),
    require => Exec["install passenger module"]
  }

  file { "${app_root}/log_archive":
    ensure  => "directory",
    mode    => "0755",
    owner   => $webapp_user,
    group   => $webapp_user
  }

  file { "/etc/logrotate.d/faims.logrotate":
    mode    => "0644",
    owner   => "root",
    group   => "root",
    content => template("webapp/faims.logrotate")
  }

  exec { "create god executable":
    path        => $rbenv_path,
    environment => $rbenv_env,
    command     => "ln -s `rbenv which god` /usr/local/bin/god",
    unless      => "test -f /usr/local/bin/god",
    logoutput   => "on_failure",
    require     => Exec["install webapp gems"]
  }

  file { "/etc/init.d/god":
    mode    => "0755",
    owner   => "root",
    group   => "root",
    content => template('webapp/god')
  }

  file { "/etc/god.conf":
    mode    => "0644",
    owner   => "root",
    group   => "root",
    content => template('webapp/god.conf')
  }

  file { "/etc/cron.daily/checkupdates":
    mode    => "0755",
    owner   => "root",
    group   => "root",
    content => template('webapp/checkupdates')
  }

}