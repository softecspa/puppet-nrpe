# == Define: nrpe::check_file_age
#
# Check file age through nrpe
#
# === Parameters:
#
# [*file*]
#   The file whose age is being checked
#
# [*age_warn*]
#   Age in seconds after which check goes warning
#
# [*age_crit*]
#   Age in seconds after which check goes critical
#
# === Examples:
#
#   nrpe::check_file_age { 'myfile check':
#     file     => '/var/www/myfile.txt',
#     age_warn => 3600,
#     age_crit => 7200,
#   }
#
# === Authors:
#
# Lorenzo Salvadorini <lorenzo.salvadorini@softecspa.it>
#
#
# Copyright 2012 Softec SpA
#
define nrpe::check_file_age($file, $age_warn, $age_crit)
{
  if ! is_integer($age_warn) {
    fail('age_warn must be an integer')
  }
  if ! is_integer($age_crit) {
    fail('age_crit must be an integer')
  }
  if empty($file) {
    fail('file cannot be an empty string')
  }

  nrpe::check { $name:
    binaryname  => 'check_file_age',
    params      => "-w ${age_warn} -c ${age_crit} -f ${file}",
  }
}
