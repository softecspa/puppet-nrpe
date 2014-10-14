# == Class: nrep::check
#
# Generic NRPE check
#
# === Actions:
#
# - creates a file for each check name check_<name>, where <name> is the
#   resource name
# - check content is based on nrpe/check.cfg.erb
#
# === Todo:
# - manage check command on nagios server
#
# === Parameters:
#
# [*checkname*]     file name of the check, if omitted the check will be named
#                   check_<name>, where <name> is the resource name;
#
# [*binaryname*]    command name used to perform the check, if omitted the command
#                   used will be check_<name>, where <name> is the resource name;
#
# [*contrib*]       this parameters manage the path of the command used to perform the
#                   check:
#                   if false, the command is not pushed from puppet master, probably
#                   because it's provided by nagios packages installed in class nrpe or
#                   elsewhere; the command must reside on the host in the standard
#                   nagios plugins directory;
#                   if true, the command resides on puppet master and will be pushed on
#                   the host in standard contrib directory for nagios plugins;
#                   default value is false;
#
# [*source*]        this value override default source path on puppet master where command resides,
#                   useful if you write the module for myapp and you want to provide the nrpe check
#                   inside your module code
#
# [*params*]        variable passed as-is to check template, after the check command: the
#                   nrpe command field will be <command> <params>, with a space in the middle
#
# [*service_template*]
#                   template used by nagios check, default value is 'generic_service'
#
define nrpe::check(
  $ensure           = present,
  $contrib          = false,
  $source           = false,
  $binaryname       = false,
  $checkname        = false,
  $params           = '',
  $service_template = 'generic-service',
  $sudo             = false,
)
{
  File {
    owner   => root,
    group   => nagios,
    mode    => 640,
  }

  # realcheckname is used only in template
  $realcheckname = $checkname ? {
    false   => "check_${name}",
    default => $checkname
  }

  $command = $binaryname ? {
    false   => "check_${name}",
    default => $binaryname
  }

  if $contrib {
    $checkpath = $nrpe::nagiospluginscontrib

    $checksource = $source ? {
      false   => "puppet:///modules/nrpe/contrib/${command}",
      default => $source,
    }

    # The resource could be already defined by another instance of the
    # same check
    # ex: check_disk, check_proc can be used multiple times on the same host
    # with different parameters
    if ! defined(File["${checkpath}/${command}"]) {
      file { "${checkpath}/${command}":
        ensure  => $ensure,
        mode    => '0750',
        source  => $checksource,
        owner   => 'root',
        group   => 'nagios',
      }
    }
  }
  else
  {
    # check binary is already present on the target host
    $checkpath = $nrpe::nagiosplugins
    if ! defined(File["${checkpath}/${command}"]) {
      file { "${checkpath}/${command}":
        ensure  => present,
        mode    => '0775',
      }
    }
  }

  # debug
  #notice ("Nrpe command for ${realcheckname} is ${checkpath}/${command}")

  file { "${nrpe::nagiosconfdir}/${realcheckname}.cfg":
    ensure  => $ensure,
    content => template('nrpe/check.cfg.erb'),
    require => [ Package['nagios-nrpe-server'], File["$checkpath/$command"] ],
    notify  => Service['nagios-nrpe-server'],
  }

  # Check exported for the nagios host
  @@nagios_service { "check_${realcheckname}_${::hostname}":
    use                   => $service_template,
    target                => "/etc/nagios/puppet/${::hostname}.cfg",
    host_name             => $::hostname,
    service_description   => "Check ${realcheckname} on ${::fqdn}",
    check_command         => "check_nrpe!${realcheckname}",
  }

}
