# VM - configuration management
node 'pm' inherits 'base-node' {

  include puppet::server
  include c2corg::collectd::client

  # TODO: mv this stuff to a decent backend system
  file { "/etc/c2corg":
    ensure => directory,
    owner  => "marc",
  }

  c2corg::backup::dir {
    ["/srv/puppetmaster", "/var/lib/puppet/ssl", "/home", "/etc/c2corg"]:
  }

}