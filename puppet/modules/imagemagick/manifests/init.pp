class imagemagick {
  require common

  apt::ppa { 'ppa:jon-severinsson/ffmpeg':
  }

  $imagemagick_packages = ["imagemagick","libmagickwand-dev","ffmpeg","libmagickcore5-extra","ghostscript","netpbm","autotrace","html2ps","ufraw-batch","dcraw","transfig","libbz2-1.0"]
  package { $imagemagick_packages:
    ensure  => "present",
    require => Apt::Ppa['ppa:jon-severinsson/ffmpeg']
  }

}