# VM
node 'test-marc' inherits 'base-node' {

  class { 'c2corg::dev::env::plain':
    developer => 'marc',
    rootaccess => false, # already has root access on every node
  }

  fact::register {
    'role': value => 'dev';
    'duty': value => 'dev';
  }

  include c2corg::varnish::instance

}
