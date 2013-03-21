class c2corg::dev::env::symfony ($developer, $rootaccess=true) {

  realize C2cinfra::Account::User[$developer]

  if $rootaccess == true {
    c2cinfra::account::user { "${developer}@root": user => $developer, account => 'root' }
  }

  include c2corg::database::dev

  include c2corg::webserver::symfony::dev
  include c2corg::webserver::carto
  include c2corg::webserver::svg

  include c2corg::apacheconf::dev

  sudoers { "root access for ${developer}":
    users    => $developer,
    type     => 'user_spec',
    commands => '(ALL) ALL',
  }

}