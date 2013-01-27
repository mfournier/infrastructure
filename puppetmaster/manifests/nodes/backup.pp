# xen VM hosted at gandi.net (95.142.173.157)
node 'backup' inherits 'base-node' {

  include c2cinfra::filesystem::backup
  include c2cinfra::backup::server
  include c2corg::webserver::ipv6gw
  include c2cinfra::collectd::node

  fact::register {
    'role': value => ['backup offsite', 'proxy ipv6'];
    'duty': value => 'prod';
  }

  collectd::plugin { ['cpu', 'df', 'disk', 'swap']: }

  collectd::config::plugin { 'df plugin config':
    plugin   => 'df',
    settings => '
      MountPoint "/dev"
      MountPoint "/dev/shm"
      MountPoint "/lib/init/rw"
      IgnoreSelected true
      ReportReserved true
      ReportInodes true
',
  }

}
