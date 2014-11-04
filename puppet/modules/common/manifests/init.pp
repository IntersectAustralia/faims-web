class common {

  class { 'apt':
  }

  exec { "update sources":
    path    => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin",
    command => '/bin/true',
    unless  => 'apt-get update'
  }

  $common_packages = ["git","build-essential"]
  package { $common_packages:
    ensure  => "present",
    require => Exec["update sources"]
  }

}