class ruby {
  require common

  $webapp_user = hiera("webapp_user")
  $ruby_version = hiera("ruby_version")
  $exec_path = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
  $rbenv_root = "/home/${webapp_user}/.rbenv"
  $rbenv_path = "${rbenv_root}/bin:${exec_path}"
  $rbenv_env = "RBENV_ROOT=${rbenv_root}"

  $ruby_packages =["libssl-dev","zlib1g-dev"]
  package { $ruby_packages:
    ensure  => "present"
  }

  exec { "clone rbenv":
    path      => $exec_path,
    user      => $webapp_user,
    command   => "git clone https://github.com/sstephenson/rbenv.git ${rbenv_root}",
    unless    => "test -d ${rbenv_root}",
    logoutput => "on_failure"
  }

  exec { "clone ruby-build":
    path      => $exec_path,
    user      => $webapp_user,
    command   => "git clone https://github.com/sstephenson/ruby-build.git ${rbenv_root}/plugins/ruby-build",
    unless    => "test -d ${rbenv_root}/plugins/ruby-build",
    logoutput => "on_failure",
    require   => Exec["clone rbenv"],
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

  exec { "build ruby version":
    path        => "${$rbenv_path}:${$exec_path}",
    user        => $webapp_user,
    environment => $rbenv_env,
    command     => "rbenv install ${ruby_version}",
    unless      => "test -d ${rbenv_root}/versions/${ruby_version}",
    logoutput   => "on_failure",
    timeout     => 1800,
    require     => [Exec["clone rbenv"],Exec["clone ruby-build"],Package[$ruby_packages]]
  }

  exec { "configure ruby version":
    path        => "${$rbenv_path}:${$exec_path}",
    user        => $webapp_user,
    environment => $rbenv_env,
    command     => "rbenv global ${ruby_version}",
    logoutput   => "on_failure",
    require     => Exec["build ruby version"]
  }

}
