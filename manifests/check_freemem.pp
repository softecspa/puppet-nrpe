# == Define: nrpe::check_freemem
#
# Check free memory through nrpe, counting OS caches as FREE memory
#
# === Parameters:
#
# [*warn*]
#   WARNING status if less than % of memory is free
#
# [*crit*]
#   CRITICAL status if less than % of memory is free
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
define nrpe::check_freemem(
  $warn     = '20',
  $crit     = '10',
  )
{
  nrpe::check { "freemem":
    binaryname  => 'check_mem.pl',
    contrib     => true,
    params      => "-f -C -w ${warn} -c ${crit}",
  }
}

