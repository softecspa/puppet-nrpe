# == Define: nrpe::check_disk
#
# Check connections through nrpe
#
# === Parameters:
#
# [*type*]
#   in or out to check respectively inbound and outboud connection
#
# [*port*]
#   port on wich monitor connection
#
# [*warn*]
#   WARNING status if more than INTEGER connection are present. Default: 50
#
# [*crit*]
#   CRITICAL status if more thann INTEGER connection are present. Default: 80
#
# === Examples:
#
# 1 - Monitoring inbound http connection on port 80 with default thresholds
#
#   nrpe::check_connection { 'apache2':
#     type  => 'in',
#     port  => '80'
#   }
#
# 2 - Monitoring outbound mysql connection on port 3306 using customized thresholds
#
#   nrpe::check_connection { 'mysql':
#     type  => 'out',
#     port  => '3306',
#     warn  => '20',
#     crit  => '50',
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
define nrpe::check_connections (
  $type = 'in',
  $port,
  $warn = '50',
  $crit = '80'
) {

  if ! is_integer($warn) {
    fail('warn must be an integer')
  }
  if ! is_integer($crit) {
    fail('crit must be an integer')
  }

  if ! is_integer($port) {
    fail('port must be an integer')
  }

  if ($type != 'in') and ($type != 'out') {
    fail('type can be only in or out')
  }

  $connection_type= $type ? {
    'in'  => '\<',
    'out' => '\>'
  }

  nrpe::check {"connections_${name}":
    binaryname  => 'check_netstat.pl',
    contrib     => true,
    params      => "-e -f -p ${connection_type}${port} -w ${warn} -c ${crit}"
  }

}
