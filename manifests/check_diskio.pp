# == Define: nrpe::check_diskio
#
# Check diskio through nrpe
#
# === Parameters:
#
# [*device to monitor*]
#   device to monitor to. If not defined $root_dev facter is the default
#
# [*warn*]
#   Warning threshold. Default: 41943040
#
# [*crit*]
#   critical threshold. Default: 52428800
#
# [*uom*]
#   Uom parameter passed to nrpe_check. Default: B
#
# === Examples:
#
#   1) monitor / disk with default threshold
#
#   nrpe::check_disk_io { 'diskio': }
#
#   2) Monitor /dev/sdb device with customized threshold
#
#   nrpe::check_diskio {'diskio_sdb':
#     device  => '/dev/sdb',
#     warn    => '41943040',
#     crit    => '52428800',
#   }
#
# === Authors:
#
# Felice Pizzurro <felice.pizzurro@softecspa.it>
#
# === Copyright:
#
# Copyright 2012 Softec SpA
#
define nrpe::check_diskio (
  $device   = $root_dev,
  $volume   = 'root',
  $warn     = '41943040',
  $crit     = '52428800',
  $uom      = 'B',
)
{

  if $volume == 'root' {
    $real_check_name = 'diskio'
  } else {
    $real_check_name = "diskio_${volume}"
  }

  nrpe::check { $real_check_name:
    binaryname => 'check_diskio',
    contrib    => true,
    params     => "--device ${device} -w ${warn} -c ${crit} --uom=${uom}",
  }

  if(!defined(Package['libreadonly-perl'])) {
    package {'libreadonly-perl': ensure => present }
  }

  if(!defined(Package['libnumber-format-perl'])) {
    package {'libnumber-format-perl': ensure => present,}
  }

  if(!defined(Package['liblist-moreutils-perl'])) {
    package {'liblist-moreutils-perl': ensure => present,}
  }

  if(!defined(Package['libfile-slurp-perl'])) {
    package {'libfile-slurp-perl': ensure => present,}
  }

  if ($lsbdistrelease >= 10) {
    if(!defined(Package['libnagios-plugin-perl'])) {
      package {'libnagios-plugin-perl': ensure => present,}
    }

    if(!defined(Package['libarray-unique-perl'])) {
      package {'libarray-unique-perl': ensure => present,}
    }
  } else {
    include perl
    perl::cpan::module {'Nagios::Plugin':}
    perl::cpan::module {'Array::Unique':}
  }

}
