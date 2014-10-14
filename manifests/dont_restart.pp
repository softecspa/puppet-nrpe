# workaround crash nagios-nrpe-server
class nrpe::dont_restart inherits nrpe {
  Service['nagios-nrpe-server'] {
    hasrestart  => false,
    restart     => '/bin/true',
  }
}
