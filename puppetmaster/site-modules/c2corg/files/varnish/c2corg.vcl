backend symfony {
  .host = "symfony-backend.c2corg"; # configure this in /etc/hosts
  .port = "80";
  .probe = {
    .url = "/probe.txt";
    .timeout = 1 s;
    .interval = 5 s;
    .window = 5;
    .threshold = 2;
  }
}

backend storage {
  .host = "storage-backend.c2corg"; # configure this in /etc/hosts
  .port = "80";
  .probe = {
    .url = "/probe.txt";
    .timeout = 1 s;
    .interval = 5 s;
    .window = 5;
    .threshold = 2;
  }
}

sub vcl_recv {

  if ( req.url == "/probe.txt" ) {
    // switch to eject varnish from haproxy
    error 200 "I am healthy";
    //error 502 "I am sick";
  }

  /* allow pictures and static content to get served directly from cache */
  if (req.url ~ "\.(gif|png|jpg|jpeg|svg)$" || req.http.host ~ "^s\..*camptocamp\.org") {
    remove req.http.Cookie;
  } else {
    if (!req.http.Cookie) {
      set req.http.X-maybe-a-robot = "1";
    }
  }

  /* define default backend */
  set req.backend = symfony;

  /* in case symfony is dead, use storage backend as failover */
  if (req.backend == symfony && !req.backend.healthy) {
    set req.backend = storage;
  }

  /* in case both backends are down, serve expired content from cache */
  elsif (req.backend == storage && !req.backend.healthy) {
    remove req.http.Cookie;
    set req.grace = 14d;
    return(lookup);
  }
}

sub vcl_fetch {

  if (req.url ~ "\.(gif|png|jpg|jpeg)$" || req.http.host ~ "^s\..*camptocamp\.org") {
    remove beresp.http.Set-Cookie; // allow pictures to get stored in cache
  } else {
    set beresp.ttl = 6h; // default TTL for generated content

    /* Remove header which prevent caching */
    if (req.http.X-maybe-a-robot) {
      remove beresp.http.Set-Cookie;
      remove beresp.http.Pragma;
      remove beresp.http.Cache-Control;
      remove beresp.http.Expires;
    }

  }

  set beresp.grace = 14d; // time to keep expired objects in cache

}

sub vcl_deliver {

  // fake cookie to prevent newcomers from never recieving any cookie at all
  if (req.http.X-maybe-a-robot) {
    unset req.http.X-maybe-a-robot;
    set resp.http.Set-Cookie = "iamabot=no; path=/";
  }

  // Add a header indicating hit/miss
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
    set resp.http.X-Cache-Hits = obj.hits;
  } else {
    set resp.http.X-Cache = "MISS";
  }
}
