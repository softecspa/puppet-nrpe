# == Define: nrpe::check_freemem
#
# Check load average through nrpe
#
# === Parameters:
#
# [*warn1*]
#   WARNING status if load average is greater than this value in the last minute
#
# [*warn5*]
#   WARNING status if load average is greater than this value in the last 5 minutes
#
# [*warn15*]
#   WARNING status if load average is greater than this value in the last 15 minutes
#
# [*crit1*]
#   WARNING status if load average is greater than this value in the last minute
#
# [*crit5*]
#   WARNING status if load average is greater than this value in the last 5 minutes
#
# [*crit15*]
#   WARNING status if load average is greater than this value in the last 15 minutes
#
# === Examples:
#
#   nrpe::check_load { 'load': }
#
# === Authors:
#
# Lorenzo Salvadorini <lorenzo.salvadorini@softecspa.it>
#
# === Copyright:
#
# Copyright 2012 Softec SpA
#
define nrpe::check_load(
  $warn1='2',
  $warn5='1.5',
  $warn15='1',
  $crit1='2.5',
  $crit5='2',
  $crit15='1.5',
  )
{
    if ! is_numeric($warn1)
    {
      fail('Variable warn1 must be numeric')
    }
    if ! is_numeric($warn5)
    {
      fail('Variable warn5 must be numeric')
    }
    if ! is_numeric($warn15)
    {
      fail('Variable warn15 must be numeric')
    }
    if ! is_numeric($crit1)
    {
      fail('Variable crit1 must be numeric')
    }
    if ! is_numeric($crit5)
    {
      fail('Variable crit5 must be numeric')
    }
    if ! is_numeric($crit15)
    {
      fail('Variable crit15 must be numeric')
    }

    # -r plugin option make it compatible with multi-core cpu
    nrpe::check{ 'load':
      params  => "-r -w ${warn1},${warn5},${warn15} -c ${crit1},${crit5},${crit15}"
    }
}

