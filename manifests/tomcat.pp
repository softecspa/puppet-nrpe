# Class: nrpe::tomcat
#
# Pusha il check di tomcat per il controllo del numero di file aperti dal tomcat
#
# Todo:
# - rifare con valori parametrici
# - usare un check-openfiles generico
#
class nrpe::tomcat {

  # TODO: perche' ridefinire il path che e' in nrpe?
  $nagiosconfdir = '/etc/nagios/conf.d/'

  file { "${nagiosconfdir}/tomcat.cfg":
    ensure      => present,
    mode        => '0664',
    owner       => 'root',
    group       => 'admin',
    content     => template('nrpe/tomcat.cfg'),
    require     => Class['nrpe'],
  }

  # TODO: perche' non riavviare il servizio con una notify?
  exec { 'exec-nrpe-tomcat-reload':
    command     => '/etc/init.d/nagios-nrpe-server force-reload',
    subscribe   => File[ "${nagiosconfdir}/tomcat.cfg" ],
    refreshonly => true,
  }
}
