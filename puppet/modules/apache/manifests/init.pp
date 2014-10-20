class apache {
  require common

  $apache_packages = ["apache2","apache2-threaded-dev","libcurl4-openssl-dev","libapr1-dev","libaprutil1-dev"]
  package { $apache_packages:
    ensure  => "present"
  }

}