class c2corg::trac {

  include apache::ssl

  $sslcert_country = "CH"
  $sslcert_organisation = "Camptocamp.org"
  apache::vhost::ssl { "dev.camptocamp.org":
    certcn  => "dev.camptocamp.org",
    sslonly => true,
    cert    => "file:///etc/puppet/dev.camptocamp.org.crt",
    certkey => "file:///etc/puppet/dev.camptocamp.org.key",
    certchain => "file:///usr/share/ca-certificates/cacert.org/cacert.org.crt",
    require => Package["ca-certificates"],
  }

  apt::preferences { "trac_from_bpo":
    package  => "trac trac-git",
    pin      => "release a=${::lsbdistcodename}-backports",
    priority => "1010",
  }

  package { ['trac', 'trac-accountmanager', 'trac-email2trac', 'trac-mastertickets', 'trac-wikirename', 'trac-git']:
    ensure  => present,
    require => Package['sqlite3'],
  }

  package { ["sqlite3", "graphviz", "libjs-jquery"]:
    ensure => present,
  }

  apache::module { "dav_svn":
    ensure => absent,
  }

  apache::directive { "svn":
    vhost     => "dev.camptocamp.org",
    directive => '
<Location /svn/c2corg>
  AuthType Basic
  AuthName Subversion
  AuthUserFile /srv/trac/projects/c2corg/conf/htpasswd

  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>
</Location>
',
  }

  @@host { "dev.camptocamp.org":
    ip  => $::ipaddress,
    tag => "internal-hosts",
  }

  apache::directive { "trac":
    vhost     => "dev.camptocamp.org",
    directive => "
Alias /tracdocs/ /usr/share/pyshared/trac/htdocs/

ScriptAlias /trac/c2corg /var/www/dev.camptocamp.org/cgi-bin/trac.cgi
",
  }

  file { "/srv/svn/repos/c2corg/hooks/post-commit":
    owner   => "root",
    group   => "root",
    mode    => 0755,
    require => Package["trac"],
    content => '#!/bin/sh
# file managed by puppet

REPOS="$1"
REV="$2"

TRAC_ENV="/srv/trac/projects/c2corg/"

/bin/sh /usr/share/doc/trac/contrib/trac-svn-hook "$REPOS" "$REV"
',
  }


  # short_open_tag conflicts with <?xml ... headers in pre-commit hook
  augeas { 'disable php short open tags':
    incl    => '/etc/php5/cli/php.ini',
    lens    => 'PHP.lns',
    changes => 'set PHP/short_open_tag Off',
    require => Package['php5-cli'],
  }


  file { "/srv/svn/repos/c2corg/hooks/pre-commit":
    owner   => "root",
    group   => "root",
    mode    => 0755,
    require => Augeas['disable php short open tags'],
    content => '#!/bin/bash
# file managed by puppet

# copied from http://blueparabola.com/blog/subversion-commit-hooks-php

REPOS="$1"
TXN="$2"

PHP="/usr/bin/php"
SVNLOOK="/usr/bin/svnlook"
AWK="/usr/bin/awk"
GREP="/bin/egrep"
SED="/bin/sed"

CHANGED=`$SVNLOOK changed -t "$TXN" "$REPOS" | $GREP "^[U|A]" | $AWK \'{print $2}\' | $GREP \\.php$`

for FILE in $CHANGED
do
    MESSAGE=`$SVNLOOK cat -t "$TXN" "$REPOS" "$FILE" | $PHP -l`
    if [ $? -ne 0 ]
    then
        echo 1>&2
        echo "***********************************" 1>&2
        echo "PHP error in: $FILE:" 1>&2
        echo `echo "$MESSAGE" | $SED "s| -| $FILE|g"` 1>&2
        echo "***********************************" 1>&2
        exit 1
    fi
done
',
  }

# trac upgrade notes:
# trac-admin . upgrade
# trac-admin . wiki upgrade
# trac-admin . deploy /tmp/toto
# cp /tmp/toto/cgi-bin/trac.cgi in cgi-bin
# cp logo in htdocs
# trac-admin . resync

}
