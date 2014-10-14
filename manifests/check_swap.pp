# == Define: nrpe::check_swap
#
# Check swap usage through nrpe
#
# === Parameters
#
# [*warn*]
#   WARNING status if less than PERCENT of swap space is free
#
# [*crit*]
#   CRITCAL status if less than PERCENT of swap space is free
#
# [*warn_mb*]
#   WARNING status if less than INTEGER MEGABYTES of swap space is free
#
# [*crit_mb*]
#   CRITCAL status if less than INTEGER MEGABYTES of swap space is free
#
# === Examples
#
#   nrpe::check_swap { 'swap':
#     warn  => '5',
#     crit  => '1',
#   }
#
# === Authors
#
# Lorenzo Salvadorini <lorenzo.salvadorini@softecspa.it>
#
# === Copyright
#
# Copyright 2012 Softec SpA
#
define nrpe::check_swap(
  $warn     = '90',
  $crit     = '80',
  $warn_mb  = '',
  $crit_mb  = '',
  )
{

  if $warn_mb {
    $warn_value = $warn_mb * 1024 * 1024
  } else {
    $warn_value = "${warn}%"
  }
  if $crit_mb {
    $crit_value = $crit_mb * 1024 * 1024
  } else {
    $crit_value = "${crit}%"
  }

  nrpe::check { "swap":
    params      => "-w ${warn}% -c ${crit}%",
  }
}
