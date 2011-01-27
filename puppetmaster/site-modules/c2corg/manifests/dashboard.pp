class c2corg::dashboard {

  Apache::Proxypass {
    notify => Exec["make index.html"],
  }

  /* required for ddraw.cgi */
  package { "libapache2-mod-proxy-html": }

  apache::module { "proxy_html":
    ensure  => present,
    require => Package["libapache2-mod-proxy-html"]
  }

  apache::vhost { "admin-backends":
    aliases => ["128.179.66.13"],
  }

  apache::proxypass { "pgfouine reports":
    location => "/pgfouine",
    url      => "http://192.168.191.126/pgfouine",
    vhost    => "admin-backends",
  }

  apache::proxypass { "haproxy":
    location => "/haproxy",
    url      => "http://192.168.192.3:8008/stats",
    vhost    => "admin-backends",
  }

  apache::proxypass { "apache server-status":
    location => "/apache-server-status",
    url      => "http://192.168.192.3/server-status",
    vhost    => "admin-backends",
  }

  apache::proxypass { "drraw rrd viewer":
    location => "/drraw.cgi",
    url      => "http://192.168.191.126/cgi-bin/drraw.cgi",
    vhost    => "admin-backends",
  }

  exec { "make index.html":
    command     => 'egrep -hi "proxypass\s+" *.conf | awk \' { printf "<li><a href=%s>%s</a></li>\n", $2, $2 } \' > ../htdocs/index.html',
    cwd         => "/var/www/admin-backends/conf/",
    refreshonly => true,
    require     => Apache::Vhost["admin-backends"],
  }

  apache::directive { "rewrite drraws hardcoded URLs":
    vhost     => "admin-backends",
    directive => "
<Location /drraw.cgi>
  SetOutputFilter proxy-html
  ProxyHTMLURLMap http://192.168.191.126/cgi-bin/drraw.cgi /drraw.cgi
</Location>
",
    require   => Apache::Module["proxy_html"],
  }

  apache::auth::htpasswd { "c2corg@camptocamp.org":
    vhost    => "admin-backends",
    username => "c2corg",
    cryptPassword => "UxYkCOe3sNVJc",
  }

  apache::auth::basic::file::user { "protect logs stats and monitoring":
    vhost => "admin-backends",
  }

}