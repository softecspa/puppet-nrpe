# == Define: nrpe::check_users
#
#   Implements nrpe check used to monitor connected users
#
# === Parameters:
#
# [*warning*]
#   Threshold of number of connected users for warning status
#
# [*critical*]
#   Threshold of number of connected users for critical status
#
# === Examples:
#
# 1) using plugin default values
#   nrpe::check_users{ 'users': }
#
# 2) using custom thresholds
#   nrpe::check_users{ 'users': 
#      warn  => '10',
#      crit  => '20',
#    }
# === Authors:
#
# Felice Pizzurro <felice.pizzurro@softecspa.it>
#
# === Copyright:
#
# Copyright 2013 Softec SpA
#
define nrpe::check_users(
  $warn = '5',
  $crit = '10',
  )
{
  nrpe::check{ 'users':
    params  => "-w $warn -c $crit"
  }
}

