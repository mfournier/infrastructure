class sympa {

  apt::preferences { "sympa_from_c2corg_repo":
    package  => "sympa",
    pin      => "release l=C2corg, a=${lsbdistcodename}",
    priority => "1010",
    before   => Package["sympa"],
  }


  package { ['sympa', 'libdbd-pg-perl']:
    ensure => present,
  }

  file { "/etc/sympa/sympa.conf":
    ensure  => present,
    content => template("sympa/sympa.conf.erb"),
    require => Package["sympa"],
    notify  => Service["sympa"],
  }

  service { 'sympa':
    ensure  => running,
    enable  => true,
    #status  => '[ $(pgrep -f "sympa/bin/(sympa|archived|task_manager|bounced).pl$" | wc -l) == 4 ]', # this seems broken in puppet 0.25.
    hasstatus => false,
    require => [File["/etc/sympa/sympa.conf"], Package['libdbd-pg-perl']],
  }

}

class sympa::mta inherits postfix {

  Postfix::Config["myorigin"] { value => $fqdn }

  postfix::config {
    "myhostname":         value => $fqdn;
    "mydestination":      value => "$fqdn,$hname";
    "mynetworks":         value => "127.0.0.0/8";
    "virtual_alias_maps": value => "hash:/etc/postfix/virtual";
    "transport_maps":     value => "hash:/etc/postfix/transport";
    "relayhost":          value => "", ensure => absent;
  }

  postfix::hash { "/etc/postfix/virtual":
    ensure => present,
  }

  postfix::hash { "/etc/postfix/transport":
    ensure => present,
  }

}

define sympa::list ($ensure='present', $subject, $anon_name, $send_from, $footer='absent') {

  File {
    ensure => $ensure,
    owner  => "sympa",
    group  => "sympa",
    mode   => 0640,
  }

  file { "/var/lib/sympa/expl/${name}":
    ensure  => $ensure ? {
      'present' => 'directory',
      default   => $ensure,
    },
    require => Package["sympa"],
  }

  file { [
    "/var/lib/sympa/expl/${name}/subscribers",
    "/var/lib/sympa/expl/${name}/stats",
    "/var/lib/sympa/expl/${name}/msg_count",
    ]:
  }

  file { "/var/lib/sympa/expl/${name}/config":
    content => template("sympa/config.erb"),
    require => Sympa::Scenari[$send_from],
    before  => [Mailalias[$name], Mailalias["${name}-owner"]],
  }

  file { "/var/lib/sympa/expl/${name}/message.footer":
    ensure  => $footer ? {
      'absent' => 'absent',
      default  => $ensure,
    },
    content => "\n-- \n${footer}",
  }

  mailalias { $name:
    ensure    => $ensure,
    recipient => "|/usr/lib/sympa/bin/queue ${name}@${hname}",
    notify    => Exec["newaliases"],
  }

  mailalias { "${name}-owner":
    ensure    => $ensure,
    recipient => "|/usr/lib/sympa/bin/bouncequeue ${name}@${hname}",
    notify    => Exec["newaliases"],
  }

}

define sympa::scenari ($ensure='present', $content) {

  file { "/etc/sympa/scenari/send.${name}":
    ensure  => $ensure,
    require => Package["sympa"],
    notify  => Service["sympa"],
    content => "title.gettext scenari ${name}

${content}
",
  }

}
