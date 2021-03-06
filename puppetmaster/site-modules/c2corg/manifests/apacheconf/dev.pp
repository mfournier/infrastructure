class c2corg::apacheconf::dev inherits c2corg::apacheconf {

  Apache::Vhost["camptocamp.org"] {
    aliases +> [
      $::hostname,
      "www.${::hostname}",
      "m.${::hostname}",
      "s.${::hostname}",
      $::fqdn,
      "${::hostname}.dev.camptocamp.org",
      "www.${::hostname}.dev.camptocamp.org",
      "m.${::hostname}.dev.camptocamp.org",
      "s.${::hostname}.dev.camptocamp.org",
      'localhost',
    ],
  }
}
