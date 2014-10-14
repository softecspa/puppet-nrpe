# == Define: nrpe::check_mysql
#
# Basi check for mysql running service
#
# === Parameters:
#
# [*hostname*]
#   Hostname to connect to
#
# [*username*]
#   Username used to check service
#
# [*password*]
#   password used to check service
#
# === Examples:
#
#   nrpe::check_mysql{ 'mysql':
#     hostname  => 'localhost',
#     username  => 'foo',
#     password  => 'bar'
#   }
#
# === Authors:
#
# Felice Pizzurro <felice.pizzurro@softecspa.it>
#
# === Copyright:
#
# Copyright 2013 Softec SpA
#
define nrpe::check_mysql(
  $hostname,
  $username,
  $password,
  )
{

  nrpe::check { "mysql":
    params      => "-H ${hostname} -u${username} -p${password}"
  }
}
