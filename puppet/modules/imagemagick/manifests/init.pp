class imagemagick {
  require common

  apt::ppa { 'ppa:mc3man/trusty-media':
  }

  exec { "update imagemagick sources":
    path    => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin",
    command => '/bin/true',
    unless  => 'apt-get update',
    timeout => 600
  }

  $imagemagick_packages = ["imagemagick","libmagickwand-dev","ffmpeg","libmagickcore5-extra","ghostscript","netpbm","autotrace","html2ps","ufraw-batch","dcraw","transfig","libbz2-1.0"]
  package { $imagemagick_packages:
    ensure  => "present",
    require => [Apt::Ppa['ppa:mc3man/trusty-media'],Exec["update imagemagick sources"]]
  }

}
