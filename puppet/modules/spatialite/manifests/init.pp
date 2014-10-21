class spatialite {
  require common

  $spatialite_packages = ["sqlite3","libproj-dev","libgeos++-dev","libfreexl-dev","libspatialite-dev"]
  package { $spatialite_packages:
    ensure  => "present"
  }

}