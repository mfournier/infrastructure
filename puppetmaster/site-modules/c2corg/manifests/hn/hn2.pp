/* PowerEdge 2950 */
class c2corg::hn::hn2 inherits c2corg::hn {

  include hardware::raid::megaraidsas
  include ipmi

  augeas { 'enable console on serial port':
    changes => [
      'set T0/runlevels 12345',
      'set T0/action respawn',
      "set T0/process '/sbin/getty -L ttyS0 115200 vt100'"
    ],
    incl    => '/etc/inittab',
    lens    => 'Inittab.lns',
    notify  => Exec['refresh init'],
  }

  @@nat::fwd {
    'forward hn2 ssh port':
      host => '3', from => '20023', to => '22',   tag => 'portfwd';
    'forward hn2 mosh port':
      host => '3', from => '6003',  to => '6003', tag => 'portfwd', proto => 'udp';
  }

}
