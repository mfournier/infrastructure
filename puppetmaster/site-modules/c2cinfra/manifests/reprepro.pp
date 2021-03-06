class c2cinfra::reprepro {

  $reprepro_basedir = "/srv/deb-repo"
  include reprepro::debian

  file { "${reprepro_basedir}/.ssh/":
    ensure => directory,
    owner  => "reprepro",
    group  => "reprepro",
  }

  # allowed uploader(s)
  c2cinfra::account::user { "marc@reprepro":
    user    => "marc",
    account => "reprepro",
    require => File[$reprepro_basedir],
  }

  # reprepro only validates packages signed by known keys.
  gnupg::pubkey { "4DA7C546":
    user    => "reprepro",
    require => [User["reprepro"], File[$reprepro_basedir]],
  }

  # generate a passwordless GPG key...
  gnupg::privkey { "pkgs@c2corg":
    user     => "reprepro",
    realname => "c2corg Package Archive Key",
    require  => [User["reprepro"], File[$reprepro_basedir]],
  }

  # ...and publish the public part.
  gnupg::pubkey::file { "pkgs@c2corg":
    user     => "reprepro",
    file     => "${reprepro_basedir}/pubkey.txt",
    require  => [User["reprepro"], File[$reprepro_basedir]],
  }

  /* configure the repository managment tool */

  reprepro::repository { "c2corg": incoming_allow => "squeeze wheezy" }

  Reprepro::Distribution {
    origin        => "C2corg",
    label         => "C2corg",
    architectures => "i386 amd64 source",
    components    => "main",
    sign_with     => "pkgs@c2corg",
  }

  reprepro::distribution { "wheezy-c2corg":
    repository  => "c2corg",
    codename    => "wheezy",
    suite       => "wheezy",
    description => "c2corg wheezy repository",
  }

  reprepro::distribution { "squeeze-c2corg":
    repository  => "c2corg",
    codename    => "squeeze",
    suite       => "squeeze",
    description => "c2corg squeeze repository",
  }

  /* setup a mini-webserver to publish all this stuff. */

  include thttpd

  file { "/etc/thttpd/thttpd.conf":
    ensure  => present,
    content => "# file managed by puppet
user=www-data
chroot
dir=$reprepro_basedir
port=80
",
    require => [Package["thttpd"], File[$reprepro_basedir]],
    notify  => Service["thttpd"],
  }

  file { "${reprepro_basedir}/install-puppet.sh":
    ensure => present,
    source => 'puppet:///puppet/install-puppet.sh',
  }

  @@host { "pkg.dev.camptocamp.org":
    ensure => absent,
    ip => $::ipaddress,
    tag => "internal-hosts",
  }

}
