class c2corg::mcollective {

  apt::preferences { "mcollective_from_c2corg_repo":
    package  => "mcollective mcollective-client mcollective-common",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
    priority => "1010",
  }

  package {
    [
      'mcollective-plugins-filemgr',
      'mcollective-plugins-package',
      'mcollective-plugins-process',
      'mcollective-plugins-puppetd',
      'mcollective-plugins-stomputil',
      'mcollective-plugins-service',
    ]: ensure => present,
  }

}
