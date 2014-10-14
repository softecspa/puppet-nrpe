# == Define: nrpe::check_disk
#
# Check disk through nrpe
#
# === Parameters:
#
# [*path*]
#   Path or partition to check
#
# [*device*]
#   Device to check
#
# [*warn*]
#   WARNING status if less than INTEGER units of disk are free
#
# [*crit*]
#   CRITICAL status if less than INTEGER units of disk are free
#
# [*mounted*]
#   If true, check if the disk is mounted. Default: true
#
# === Examples:
#
#   nrpe::check_disk { 'root':
#     path  => '/',
#     warn  => '5%',
#     crit  => '1%',
#   }
#
# === Todo:
#
# Manage multiple -p options (path as array?)
#
# === Authors:
#
# Lorenzo Salvadorini <lorenzo.salvadorini@softecspa.it>
#
# === Copyright:
#
# Copyright 2012 Softec SpA
#
define nrpe::check_disk(
  $path     = '',
  $device   = '',
  $warn     = '20%',
  $crit     = '10%',
  $mounted  = true,
  )
{
  if $path and $device {
    fail('Only one parameter between path and device must be specified')
  }

  $mounted_opt = $mounted? {
    true  => '-E ',
    false => ''
  }

  if $path {
    $monitor_target = "${mounted_opt}-p $path"
  } else {
    $monitor_target = "-x $device"
  }

  nrpe::check { "disk_${name}":
    binaryname  => 'check_disk',
    params      => "-w ${warn} -W ${warn} -c ${crit} -K ${crit} ${monitor_target}"
  }
}
