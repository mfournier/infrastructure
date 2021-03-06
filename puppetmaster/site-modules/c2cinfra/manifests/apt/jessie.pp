class c2cinfra::apt::jessie inherits c2cinfra::apt {

  Apt::Preferences["squeeze"] {
    priority => "50",
  }

  Apt::Preferences["squeeze-proposed-updates"] {
    priority => "50",
  }

  Apt::Preferences["wheezy"] {
    priority => "50",
  }

  Apt::Preferences["wheezy-proposed-updates"] {
    priority => "50",
  }

  Apt::Preferences["jessie"] {
    priority => "990",
  }

  Apt::Preferences["jessie-proposed-updates"] {
    priority => "990",
  }

  Apt::Conf["01default-release"] {
    content => 'APT::Default-Release "testing";', # warning: changing this can break the system !
  }

}
