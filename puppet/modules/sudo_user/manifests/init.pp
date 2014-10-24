class sudo_user {
  require common

  $webapp_user = hiera("webapp_user")

  file { "/etc/sudoers.d/${$webapp_user}":
    mode    => "0644",
    owner   => "root",
    group   => "root",
    content => template('sudo_user/user')
  }

}