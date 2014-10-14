# == Define: nrpe::check_haproxy
#
# Check free memory through nrpe, counting OS caches as FREE memory
#
# === Parameters:
#
# [*warn*]
#   WARNING status if session numer is grater than this percentage of maximum connection
#
# [*crit*]
#   CRITICAL status if session numer is grater than this percentage of maximum connection
#
# [*proxy*]
#   Proxy name to monitor
#
# [*socket*]
#   Socket path to perform check
#
# === Examples:
#
#   nrpe::check_freemem { 'free':
#     warn  => '10',
#     crit  => '5',
#   }
#
# === Todo:
#
# Support $warn_mb and $crit_mb parameters to check
# absolute values of free MegaBytes of ram.
#
# === Authors:
#
# Lorenzo Salvadorini <lorenzo.salvadorini@softecspa.it>
#
# === Copyright:
#
# Copyright 2012 Softec SpA
#
define nrpe::check_haproxy(
  $warn     = '60',
  $crit     = '80',
  $socket   = '/var/run/haproxy.sock',
  $proxy    = '',
  )
{

  $proxy_name = $proxy ? {
    ''      => $name,
    default => $proxy,
  }

  nrpe::check { "haproxy_${proxy_name}":
    binaryname  => 'check_haproxy_stats.pl',
    contrib     => true,
    params      => "-p ${proxy_name} -s ${socket} -w ${warn} -c ${crit}",
    sudo        => true
  }

  if !defined(Softec_sudo::Conf['haproxy']) {
    softec_sudo::conf {'haproxy':
      source  => 'puppet:///modules/nrpe/etc/sudo_haproxy'
    }
  }
}

