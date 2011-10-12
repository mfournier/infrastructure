class c2corg::preprod::autoupdate {

  /* hackish stuff to autotomatically install and update c2corg codebase */
  vcsrepo { "/srv/www/camptocamp.org/":
    ensure   => "latest",
    provider => "svn",
    source   => "https://dev.camptocamp.org/svn/c2corg/trunk/camptocamp.org/",
    notify   => Exec["c2corg refresh"],
  }

  vcsrepo { "/srv/www/meta.camptocamp.org":
    ensure   => "latest",
    provider => "svn",
    source   => "https://dev.camptocamp.org/svn/c2corg/trunk/meta.camptocamp.org/",
  }

  file { "c2corg preprod.ini":
    path    => "/srv/www/camptocamp.org/deployment/preprod.ini",
    source  => "file:///srv/www/camptocamp.org/deployment/conf.ini-dist",
    require => Vcsrepo["/srv/www/camptocamp.org/"],
    notify  => [Exec["c2corg refresh"], Exec["c2corg install"]],
  }

  include c2corg::password
  $sitename = "pre-prod.dev.camptocamp.org"

  $c2corg_vars = inline_template("<%=

  c2corg_vars = {
    'DB_USER'               => '${c2corg::password::www_db_user}',
    'DB_PASS'               => '${c2corg::password::prod_db_pass}',
    'SERVER_NAME'           => 'www.${sitename}',
    'MOBILE_VERSION_HOST'   => 'm.${sitename}',
    'CLASSIC_VERSION_HOST'  => 'www.${sitename}',
    'STATIC_HOST'           => 's.${sitename}',
    'STATIC_BASE_URL'       => 'http://s.${sitename}',
  }

 c2corg_vars.map{ |k,v| \"#{k}=#{v}\" }.join(';')

%>")

  exec { "c2corg install":
    command => "C2CORG_VARS='${c2corg_vars}' php c2corg --install --conf preprod",
    cwd     => "/srv/www/camptocamp.org/",
    notify  => Service["apache"],
    logoutput   => true,
    refreshonly => true,
  }

  exec { "c2corg refresh":
    command => "C2CORG_VARS='${c2corg_vars}' php c2corg --refresh --conf preprod --build",
    cwd     => "/srv/www/camptocamp.org/",
    require => Exec["c2corg install"],
    notify  => Service["apache"],
    logoutput   => true,
    refreshonly => true,
  }
}