# PowerEdge 1850
node 'hn5' inherits 'base-node' {

  include c2cinfra::hn::hn5

  include c2cinfra::vip

  class { 'lxc::host': } ->
  class { 'c2cinfra::containers': }

  fact::register {
    'role': value => 'HN lxc, VIP haproxy';
    'duty': value => 'prod';
  }

}
