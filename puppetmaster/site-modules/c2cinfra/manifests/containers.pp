class c2cinfra::containers {

  case $::hostname {
    'hn0': {

    }

    'hn2': {

      lxc::container { 'www-failover.pse.infra.camptocamp.org':
        ctid   => 70,
        suite  => 'squeeze',
        fstype => 'ext3',
        fssize => '180G',
      }

      lxc::container { 'monit.pse.infra.camptocamp.org':
        ctid   => 126,
        suite  => 'squeeze',
        fstype => 'ext3',
        fssize => '120G',
      }

      lxc::container { 'test-alex.pse.infra.camptocamp.org':
        ctid   => 201,
        suite  => 'squeeze',
        fssize => '15G',
      }

      lxc::container { 'test-xbrrr.pse.infra.camptocamp.org':
        ctid   => 202,
        suite  => 'squeeze',
        fssize => '15G',
      }

      lxc::container { 'test-marc.pse.infra.camptocamp.org':
        ctid   => 203,
        suite  => 'squeeze',
        fssize => '15G',
      }

      lxc::container { 'test-stef74.pse.infra.camptocamp.org':
        ctid   => 204,
        suite  => 'wheezy',
        fssize => '3G',
      }

      lxc::container { 'test-saimon.pse.infra.camptocamp.org':
        ctid   => 206,
        suite  => 'wheezy',
        fssize => '4G',
      }

      lxc::container { 'test-gottferdom.pse.infra.camptocamp.org':
        ctid   => 207,
        suite  => 'squeeze',
        fssize => '15G',
      }

    }

    'hn5': {

      lxc::container { 'rproxy.pse.infra.camptocamp.org':
        ctid   => 60,
        suite  => 'wheezy',
        fssize => '38G',
      }

      lxc::container { 'memcache1.pse.infra.camptocamp.org':
        ctid   => 66,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'lists.pse.infra.camptocamp.org':
        ctid   => 102,
        suite  => 'squeeze',
        fssize => '3G',
      }

      lxc::container { 'dnscache.pse.infra.camptocamp.org':
        ctid   => 50,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'msgbroker.pse.infra.camptocamp.org':
        ctid   => 55,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'pkg.pse.infra.camptocamp.org':
        ctid   => 125,
        suite  => 'wheezy',
        fssize => '3G',
      }

      lxc::container { 'pm.pse.infra.camptocamp.org':
        ctid   => 101,
        suite  => 'squeeze',
        fssize => '6G',
      }

      lxc::container { 'dev.pse.infra.camptocamp.org':
        ctid   => 103,
        suite  => 'squeeze',
        fssize => '6G',
      }

      lxc::container { 'content-factory.pse.infra.camptocamp.org':
        ctid   => 140,
        suite  => 'squeeze',
        fssize => '10G',
      }

      lxc::container { 'pre-prod.pse.infra.camptocamp.org':
        ctid   => 141,
        suite  => 'squeeze',
        fssize => '15G',
      }

    }

    'hn6': {

      lxc::container { 'stats.pse.infra.camptocamp.org':
        ctid   => 75,
        suite  => 'wheezy',
        fssize => '3G',
      }

      lxc::container { 'memcache0.pse.infra.camptocamp.org':
        ctid   => 65,
        suite  => 'wheezy',
        fssize => '2G',
      }

      lxc::container { 'collectd0.pse.infra.camptocamp.org':
        ctid   => 127,
        suite  => 'wheezy',
        fssize => '80G',
      }

    }
  }
}
