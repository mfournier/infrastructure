# VM
node 'pkg' inherits 'base-node' {

  include c2cinfra::reprepro

  fact::register {
    'role': value => 'repository de paquets';
    'duty': value => 'prod';
  }

  c2cinfra::backup::dir { '/srv/deb-repo/': }

}
