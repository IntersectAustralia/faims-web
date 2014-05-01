class webapp {

  $webapp_user = hiera("webapp_user")
  $webapp_version = hiera("webapp_version")
  $ruby_version = hiera("ruby_version")
  $exec_path = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
  $app_root = "/var/www/faims"
  $rbenv_root = "/home/${webapp_user}/.rbenv"
  $rbenv_path = "${rbenv_root}/bin:${exec_path}"
  $rbenv_env = "RBENV_ROOT=${rbenv_root}"

  # Install common packages
  $common_packages = ["git"]
  package { $common_packages:
    ensure  => "present"
  }

  # Install Spatialite
  $spatialite_packages = ["build-essential","sqlite3","libproj-dev","libgeos++-dev","libfreexl-dev","libspatialite-dev"]
  package { $spatialite_packages:
    ensure  => "present"
  }

  # Install rbenv
  exec { "clone rbenv":
    path      => $exec_path,
    command   => "git clone https://github.com/sstephenson/rbenv.git ${rbenv_root}",
    unless    => "test -d ${rbenv_root}",
    logoutput => "on_failure",
    require   => Package[$common_packages],
    user      => $webapp_user
  }

  exec { "clone ruby-build":
    path      => $exec_path,
    command   => "git clone https://github.com/sstephenson/ruby-build.git ${rbenv_root}/plugins/ruby-build",
    unless    => "test -d ${rbenv_root}/plugins/ruby-build",
    logoutput => "on_failure",
    require   => [Exec["clone rbenv"], Package[$common_packages]],
    user      => $webapp_user
  }

  file_line { "configure rbenv root":
    path    => "/home/${webapp_user}/.profile",
    line    => "export RBENV_ROOT=${rbenv_root}"
  }

  file_line { "configure rbenv path":
    path    => "/home/${webapp_user}/.profile",
    line    => "export PATH=\$RBENV_ROOT/bin:\$PATH",
    require => File_line["configure rbenv root"]
  }

  file_line { "configure rbenv shell":
    path    => "/home/${webapp_user}/.profile",
    line    => "eval \"$(rbenv init -)\"",
    require => File_line["configure rbenv path"]
  }

  # Build ruby version
  $ruby_packages =["libssl-dev","libxslt1-dev"]
  package { $ruby_packages:
    ensure  => "present"
  }

  exec { "build ruby version":
    path        => $rbenv_path,
    command     => "rbenv install ${ruby_version}",
    environment => $rbenv_env,
    timeout     => "3000",
    unless      => "test -d ${rbenv_root}/versions/${ruby_version}",
    logoutput   => "on_failure",
    require     => [Exec["clone ruby-build"], Package[$ruby_packages]],
    user        => $webapp_user
  }

  exec { "configure ruby version":
    path        => $rbenv_path,
    command     => "rbenv global ${ruby_version}",
    environment => $rbenv_env,
    logoutput   => "on_failure",
    require     => Exec["build ruby version"],
    user        => $webapp_user
  }

  # Setup App
  exec { "install bundler gem":
    path        => $rbenv_path,
    command     => "su - ${webapp_user} -c \"gem install bundler\"",
    unless      => "su - ${webapp_user} -c \"gem list bundler -i\"",
    environment => $rbenv_env,
    logoutput   => "on_failure",
    require     => [Exec["configure ruby version"], File_line["configure rbenv shell"]]
  }

  exec { "install webapp gems":
    path        => $rbenv_path,
    command     => "su - ${webapp_user} -c \"cd ${app_root} && bundle install\"",
    unless      => "su - ${webapp_user} -c \"cd ${app_root} && bundle check\"",
    environment => $rbenv_env,
    logoutput   => "on_failure",
    require     => Exec["install bundler gem"]
  }

  exec { "setup app":
    path      => $rbenv_path,
    command   => "su - ${webapp_user} -c \"cd ${app_root} && rake db:create db:migrate db:seed modules:clean modules:setup\"",
    environment => $rbenv_env,
    logoutput => "on_failure",
    require   => Exec["install webapp gems"]
  }

  # Install apache & passenger
  $apache_packages = ["apache2","apache2-threaded-dev","libcurl4-openssl-dev","libapr1-dev","libaprutil1-dev"]
  package { $apache_packages:
    ensure  => "present"
  }

  exec { "install passenger gem":
    path        => $rbenv_path,
    command     => "su - ${webapp_user} -c \"gem install passenger\"",
    unless      => "su - ${webapp_user} -c \"gem list passenger -i\"",
    environment => $rbenv_env,
    logoutput   => "on_failure",
    require     => [Exec["configure ruby version"], Package[$apache_packages], File_line["configure rbenv shell"]]
  }

  exec { "link passenger gem":
    path        => $rbenv_path,
    command     => "ln -s `su - ${webapp_user} -c \"passenger-config --root\"` /etc/apache2/passenger",
    unless      => "test -d /etc/apache2/passenger",
    environment => $rbenv_env,
    logoutput   => "on_failure",
    require     => Exec["install passenger gem"]
  }

  exec { "install passenger module":
    path        => $rbenv_path,
    command     => "su - ${webapp_user} -c \"passenger-install-apache2-module --auto\"",
    unless      => "test -f /etc/apache2/passenger/buildout/apache2/mod_passenger.so",
    environment => $rbenv_env,
    logoutput   => "on_failure",
    require     => Exec["link passenger gem"]
  }

  file { "/etc/apache2/conf-enabled/faims.conf":
    mode    => "0644",
    owner   => $webapp_user,
    group   => $webapp_user,
    content => template("webapp/faims.conf"),
    require => [Package[$apache_packages], Exec["install passenger module"]],
    notify  => Service["apache2"]
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

  service { "apache2":
    ensure  => "running",
    enable  => "true",
    require => [Exec["install passenger module"], File["/etc/apache2/conf-enabled/faims.conf"], Exec["setup app"]]
  }

  # Install god
  exec { "create god executable":
    path        => $rbenv_path,
    command     => "ln -s `rbenv which god` /usr/local/bin/god",
    unless      => "test -f /usr/local/bin/god",
    environment => $rbenv_env,
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
    content => template('webapp/god.conf'),
    notify  => Service["god"]
  }

  service { "god":
    ensure  => "running",
    enable  => "true",
    require => [File["/etc/init.d/god"], File["/etc/god.conf"], Exec["setup app"]]
  }

}