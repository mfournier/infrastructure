class c2corg::common::packages {

  include gnupg

  package { [
    "arping", "at",
    "bash-completion",
    "curl", "cron", "cvs",
    "dnsutils",
    "elinks",
    "git-core", "git-svn",
    "less", "locales-all", "lsb-release",
    "m4", "make", "mtr-tiny",
    "netcat", "nmap", "nscd", "ntp",
    "openssh-server",
    "patch", "pwgen",
    "rsyslog", "rsync",
    "screen", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "tshark",
    "unzip",
    "vim",
    "wget"
    ]: ensure => installed
  }

  case $operatingsystem {
    "Debian": {
      package { [
        "ethtool", "iotop", "iptraf", "lsof", "strace", "traceroute", "vlan",
        ]: ensure => installed
      }
    }
    "GNU/kFreeBSD": {
    }
  }

}

class c2corg::common::services {

  /* Base services */
  service { "cron":
    ensure => running, enable => true,
    require => Package["cron"],
  }

  service { "atd":
    ensure => running, enable => true,
    require => Package["at"],
  }

  service { "rsyslog":
    ensure => running, enable => true, hasstatus => true,
    require => Package["rsyslog"],
  }

  service { "nscd":
    ensure => running, enable => true, hasstatus => true,
    require => Package["nscd"],
  }

  service { "ntp":
    ensure => running, enable => true, hasstatus => true,
    require => Package["ntp"],
  }

  service { "ssh":
    ensure => running, enable => true, hasstatus => true,
    require => Package["openssh-server"],
  }

  service { "sysstat":
    require => Package["sysstat"],
  }

}

class c2corg::common::config {

  file { "/etc/resolv.conf":
    content => "# file managed by puppet
search c2corg
nameserver 8.8.8.8
nameserver 8.8.4.4
options rotate edns0
",
  }

  file { "/etc/timezone":
    content => "Europe/Zurich\n",
    notify  => Exec["configure timezone"],
  }

  exec { "configure timezone":
    command     => "dpkg-reconfigure --priority critical tzdata",
    refreshonly => true,
  }

  case $operatingsystem {
    "Debian": {
      if $is_virtual != true {
        # kernel must reboot if panic occurs
        sysctl::set_value { "kernel.panic": value => "60" }
        # disable tcp_sack due to Cisco bug in epnet routers
        sysctl::set_value { "net.ipv4.tcp_sack": value => "0" }
      }
    }
    "GNU/kFreeBSD": {
      # avoid sysctl type failure
      file { "/etc/sysctl.conf": ensure => present }
    }
  }

  augeas { "sysstat history":
    context => "/files/etc/default/sysstat",
    changes => ["set HISTORY 30", "set ENABLED true"],
    notify  => Service["sysstat"],
  }

  augeas { "disable ctrl-alt-delete":
    context => "/files/etc/inittab/*[action='ctrlaltdel']/",
    changes => [
      "set runlevels 12345",
      "set process '/bin/echo ctrlaltdel disabled'"
    ],
    notify  => Exec["refresh init"],
  }

  exec { "refresh init":
    refreshonly => true,
    command     => "kill -HUP 1",
  }

}
