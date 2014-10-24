class sudo_user {
  require common

  file { "/etc/sudoers.d/www-data":
    mode    => "0644",
    owner   => "root",
    group   => "root",
    content => template('sudo_user/user')
  }

}