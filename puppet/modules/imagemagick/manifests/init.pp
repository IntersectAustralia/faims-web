class imagemagick {
  require common

  apt::ppa { 'ppa:jon-severinsson/ffmpeg':
  }

  $imagemagick_packages = ["imagemagick","libmagickwand-dev","ffmpeg"]
  package { $imagemagick_packages:
    ensure  => "present"
  }

}