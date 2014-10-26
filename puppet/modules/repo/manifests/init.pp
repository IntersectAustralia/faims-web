class repo {
  require common

  $webapp_user = hiera("webapp_user")
  $app_root = hiera("app_root")
  $app_source = hiera("app_source")

  if $app_tag {
    vcsrepo { $app_root:
      ensure   => latest,
      provider => git,
      source   => $app_source,
      revision => $app_tag,
      user     => $webapp_user,
    }
  } else {
    vcsrepo { $app_root:
      ensure   => latest,
      provider => git,
      source   => $app_source,
      revision => hiera("app_tag"),
      user     => $webapp_user,
    }
  }
}