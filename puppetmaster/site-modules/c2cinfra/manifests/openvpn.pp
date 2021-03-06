class c2cinfra::openvpn {

  package { 'openvpn': ensure => present } ->

  etcdefault { 'enable vpns at boot':
    key   => 'AUTOSTART',
    file  => 'openvpn',
    value => 'c2corg',
  } ->

  # just using openvpn as a convenient tunnel, nothing secret hidden
  # behind it, so I don't care saving the CA in the VCS.
  file { '/etc/openvpn/keys':
    source  => 'puppet:///modules/c2cinfra/openvpn/keys/',
    recurse => true,
    force   => true,
    purge   => true,
    notify  => Service['openvpn'],
  } ->

  file { '/etc/openvpn/c2corg.conf':
    source => 'puppet:///modules/c2cinfra/openvpn/server.conf',
  } ~>

  service { 'openvpn':
    ensure    => running,
    hasstatus => true,
    enable    => true,
  }

  collectd::config::plugin { 'openvpn status file':
    plugin   => 'openvpn',
    settings => '
  StatusFile "/var/run/openvpn-status.log"
  ImprovedNamingSchema "true"
',
  }

  file { '/etc/pam.d/c2corg-openvpn':
    content => '# file managed by puppet
auth required pam_pwdfile.so pwdfile /etc/openvpn/passwd
account required pam_permit.so
',
  }

  # fetch htpasswd file from trac, available in a fact
  file { '/etc/openvpn/passwd':
    content => pdbfactquery('dev', 'openvpn_pwdfile'),
    mode    => 0600,
    require => Package['openvpn'],
  }

}
