# VM
node 'test-stef74' inherits 'base-node' {

  class { 'c2corg::dev::env::plain':
    developer => 'stef74',
  }

  include '::c2corg::database::dev'

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

  Etcdefault {
    file  => 'jetty',
  }

  package { 'solr-jetty':
    ensure => present,
  } ->
  # workaround for bug https://bugs.launchpad.net/ubuntu/+source/lucene-solr/+bug/1099320
  file { '/var/lib/jetty/webapps/solr':
    ensure => link,
    target => '/usr/share/solr/web',
  } ->
  etcdefault {
    'start jetty at boot time': key => 'NO_START', value => '0';
    'bind jetty to public interface': key => 'JETTY_HOST', value => '0.0.0.0';
  } ~>
  service { 'jetty':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

}
