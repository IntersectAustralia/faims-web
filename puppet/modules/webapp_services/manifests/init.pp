class webapp_services {
  require webapp

  service { "god":
    ensure     => "running",
    enable     => "true",
    hasrestart => "true"
  }

  service { "apache2":
    ensure     => "running",
    enable     => "true",
    hasrestart => "true"
  }

}