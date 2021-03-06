class c2cinfra::common::packages {

  include gnupg

  package { [
    "ack-grep", "arping", "at", "atop",
    "bash-completion", "bc", "bind9-host", "bsdmainutils", "bzr",
    "curl", "cron", "cvs",
    "dc", "dnsutils",
    "elinks", "emacs23-nox", "ethtool",
    "fping", "ftp",
    "git-core", "git-svn",
    "htop",
    "iputils-ping", "iotop", "iptraf", "iso-codes",
    "less", "locales-all", "logrotate", "lsb-release", "lsof",
    "man-db", "m4", "make", "mosh", "mtr-tiny",
    "netcat", "nmap", "ntp",
    "patch", "psmisc", "pwgen",
    "rsync",
    "screen", "strace", "sudo", "subversion", "subversion-tools", "sysstat",
    "tcpdump", "telnet", "time", "tmux", "traceroute", "tshark",
    "unzip",
    "vim", "vlan",
    "whois", "wget",
    "xauth",
    ]: ensure => installed
  }

  case $::lsbdistcodename {
    "squeeze": {
      apt::preferences { "misc_pkgs_from_bpo":
        package  => "mosh",
        pin      => "release a=${::lsbdistcodename}-backports",
        priority => "1010",
      }

    }
  }

}
