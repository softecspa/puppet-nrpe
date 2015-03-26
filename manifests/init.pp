# == Class Nrpe
#
# Install Nagios NRPE and manage the service
#
# === Actions:
#
# - Install nrpe-server
# - Install basic, standard and extra plugins from ubuntu repository
#
# === Requires
#
# - perlmodules
#
#
class nrpe ($allowed_hosts)
{
  $nagiosbasedir        = '/etc/nagios'
  $nrpe_cfg             = "${nagiosbasedir}/nrpe.cfg"
  $nagiosconfdir        = "${nagiosbasedir}/conf.d"
  $lastrestart          = "${nagiosbasedir}/.puppet"
  $nagiosplugins        = '/usr/lib/nagios/plugins'
  $nagiospluginscontrib = "${nagiosplugins}/contrib"

  # default settings for files
  File {
    owner   => 'root',
    group   => 'admin',
    mode    => '0664',
  }

  #546: Nagios Plugin check_diskio
  package {
    "libfile-slurp-perl":           ensure => present;
    "libnumber-format-perl":        ensure => present;
    "libreadonly-perl":             ensure => present;
    "libparams-validate-perl":      ensure => present;
  }

  if $::lsbdistid == 'Ubuntu' {
    package { 'nagios-plugins-extra':
        ensure => present;
    }
  }

  package {
    'nagios-nrpe-server':       ensure => present;
    'nagios-plugins-basic':     ensure => present;
    'nagios-plugins-standard':  ensure => present;
  }

  # inclusione directory 'conf.d' nell nrpe server
  file_line {'include-nagios-conf':
    ensure  => present,
    path    => $nrpe_cfg,
    line    => "include_dir=${nagiosconfdir}",
    require => Package['nagios-nrpe-server'],
    notify  => Service['nagios-nrpe-server'],
  }

  #643: set nrpe_local perms
  file { "${nagiosbasedir}/nrpe_local.cfg":
    ensure  => present,
    mode    => '0640',
    owner   => 'root',
    group   => 'nagios',
    require => Package['nagios-nrpe-server'],
    notify  => Service['nagios-nrpe-server'],
  }

  file { $nagiosconfdir:
    ensure  => directory,
    mode    => '0750',
    owner   => 'root',
    group   => 'nagios',
    notify  => Service['nagios-nrpe-server'],
    require => Package['nagios-nrpe-server'],
  }

  file { "${nagiosconfdir}/allowed_hosts.cfg":
    ensure  => present,
    content => template('nrpe/allowed_hosts.cfg.erb'),
    mode    => '0640',
    owner   => 'root',
    group   => 'nagios',
    notify  => Service['nagios-nrpe-server'],
    require => File[$nagiosconfdir],
  }

  # TODO: eliminare, serve solo ad eliminare il vecchio file
  file { "${nagiosconfdir}/softec.cfg":
    ensure  => absent,
    notify  => Service['nagios-nrpe-server'],
  }

  # contrib plugins (pushati ricorsivamente, #587)
  # TODO: modalita' deprecata: meglio mettere il plugin aggiuntivo insieme al check, cosi' si pusha dove serve
  file { $nagiospluginscontrib:
    ensure  => directory,
    mode    => '0750',
    owner   => 'root',
    group   => 'nagios',
    require => [ Package['nagios-nrpe-server'], Package['nagios-plugins-basic'], Package['nagios-plugins-standard'] ],
  #  source  => 'puppet:///modules/nrpe/contrib/',
  #  ignore  => '.svn',
  #  recurse => true,
  #  purge   => false,
  }

  service { 'nagios-nrpe-server':
    name        => 'nagios-nrpe-server',
    ensure      => running,
    enable      => true,
    hasstatus   => false,
    pattern     => '/usr/sbin/nrpe',
    require     => Package['nagios-nrpe-server'],
  }

}
