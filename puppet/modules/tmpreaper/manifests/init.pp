class tmpreaper {
  require common

  $tmpreaper_packges = ["tmpreaper"]
  package { $tmpreaper_packges:
    ensure  => "present"
  }

  file_line { "enable tmpreaper":
    path      => "/etc/tmpreaper.conf",
    line      => "#SHOWWARNING=true",
    match     => "SHOWWARNING=true",
    ensure    => "present",
    require   => Package[$tmpreaper_packges]
  }

  file_line { "configure tmpreaper delay":
    path      => "/etc/tmpreaper.conf",
    line      => "TMPREAPER_DELAY='0'",
    match     => "^TMPREAPER_DELAY=*",
    ensure    => "present",
    require   => Package[$tmpreaper_packges]
  }

  file_line { "configure tmpreaper project dirs":
    path      => "/etc/tmpreaper.conf",
    line      => "TMPREAPER_PROTECT_EXTRA='passenger*/ passenger*/* passenger*/*/* passenger*/*/*/* god* ssh*/ ssh*/* unity* .*'",
    ensure    => "present",
    require   => Package[$tmpreaper_packges]
  }

  service { "cron":
    ensure  => "running",
    enable  => "true"
  }

}