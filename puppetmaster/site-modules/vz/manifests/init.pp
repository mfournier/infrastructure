class vz {

  package { ["vzctl", "vzquota", "vzdump", "bridge-utils", "debootstrap"]:
    ensure => present,
  }

  package { "linux-image-2.6.32-5-openvz-amd64":
    ensure  => present,
  }

  sysctl::set_value {
    "net.ipv4.ip_forward":                  value => "1";
    "net.ipv4.conf.default.proxy_arp":      value => "0";
    "net.ipv4.conf.all.rp_filter":          value => "1";
    "net.ipv4.conf.default.send_redirects": value => "1";
    "net.ipv4.conf.all.send_redirects":     value => "0";
  }

  service { "vz":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [Package["vzctl"], Mount["/var/lib/vz"]],
  }

  logical_volume { "vz":
    ensure       => present,
    volume_group => "vg0",
    initial_size => "10G",
  }

  filesystem { "/dev/vg0/vz":
    ensure  => present,
    fs_type => "ext3",
    require => Logical_volume["vz"],
  }

  mount { "/var/lib/vz":
    ensure  => mounted,
    options => "auto",
    fstype  => "ext3",
    device  => "/dev/vg0/vz",
    require => [Filesystem["/dev/vg0/vz"], Package["vzctl"]],
  }

  file { [
    "/var/lib/vz/lock",
    "/var/lib/vz/private",
    "/var/lib/vz/template",
    "/var/lib/vz/template/cache",
    "/var/lib/vz/dump",
    "/var/lib/vz/root"]:
    ensure  => directory,
    require => Mount["/var/lib/vz"],
  }

  file { "/etc/vz/conf/ve-vps.unlimited.conf-sample":
    source  => "puppet:///vz/ve-vps.unlimited.conf-sample",
    require => Package["vzctl"],
  }

  augeas { "compress vzctl logfiles":
    changes => "set /files/etc/logrotate.d/vzctl/rule/compress compress",
    require => Package["vzctl"],
  }

}

define vz::ve ($ensure="running", $hname, $template="debian-5.0-amd64-with-puppet", $config="vps.unlimited", $net="192.168.191") {

  case $ensure {
    present,stopped,running: {

      exec { "vzctl create $name":
        command => "vzctl create $name --ostemplate $template --config $config --hostname $hname",
        creates => ["/etc/vz/conf/${name}.conf", "/var/lib/vz/private/${name}/"],
        require => Package["vzctl"],
      }

      exec { "configure VE $name":
        command => "vzctl set $name --name $hname --hostname $hname --ipadd ${net}.${name} --nameserver 8.8.8.8 --save",
        unless  => "egrep -q 'IP_ADDRESS=.?${net}.${name}.?' /etc/vz/names/${hname}",
        require => Exec["vzctl create $name"],
      }

      # start/stop VE
      case $ensure {
        running: {
          exec { "start VE $name":
            command => "vzctl start $name",
            onlyif  => "vzlist -a -H -o ctid,status | egrep '${name}\s+stopped'",
            require => Exec["configure VE $name"],
          }

          exec { "enable boottime start for $name":
            command => "vzctl set $name --onboot yes --save",
            unless  => "egrep -q 'ONBOOT=.?yes.?' /etc/vz/names/${hname}",
            require => Exec["configure VE $name"],
          }
        }

        stopped: {
          exec { "stop VE $name":
            command => "vzctl stop $name",
            onlyif  => "vzlist -a -H -o ctid,status | egrep '${name}\s+running'",
            require => Exec["configure VE $name"],
          }

          exec { "disable boottime start for $name":
            command => "vzctl set $name --onboot no --save",
            onlyif  => "egrep -q 'ONBOOT=.?yes.?' /etc/vz/names/${hname}",
            require => Exec["configure VE $name"],
          }
        }
      }

    }

    absent: {
      exec { "vzctl destroy $name":
        command => "vzctl stop $name; vzctl destroy $name",
        onlyif  => "test -e /var/lib/vz/private/${name}",
      }

    }

  }
}

define vz::fwd ($net="192.168.191", $ve, $from, $to, $iface="eth2") {

  iptables { "forward from ${from} to ${net}.${ve}:${to}":
    chain       => "PREROUTING",
    table       => "nat",
    proto       => "tcp",
    iniface     => $iface,
    todest      => "${net}.${ve}:${to}",
    dport       => $from,
    jump        => "DNAT",
  }
}
