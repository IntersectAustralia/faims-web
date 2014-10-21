class common {

  class { 'apt':
    always_apt_update => true,
  }

  $common_packages = ["git","build-essential"]
  package { $common_packages:
    ensure  => "present"
  }

}