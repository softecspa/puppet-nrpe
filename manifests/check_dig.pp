# == Class: nrpe::check_dig
#
# Check with dig if a DNS record exists and it resolved with a date ip address
#
# === Parameters:
# [*record*]
#   record to monitor
#
# [*string_check*]
#   content of the resolved record. If none is specified no record content is checked in. Only reord existence will be checked
#
# [*dns_host*]
#   dns server to perform dig. If none is specified, first nameserver entry of /etc/resolv.conf is used
#
# [*type*]
#   record type that resolution expects
#
# === Author
#   Felice Pizzurro <felice.pizzurro@softecspa.it>
#
define nrpe::check_dig(
    $record,
    $string_check ='',
    $dns_host     ='$(grep -m1 nameserver /etc/resolv.conf | awk \'{print $2}\')',
    $type         = 'A',
  )
{

  if ($string_check != '') and ($type == 'A') and (! $string_check =~ /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/) {
    fail ('ip_address parameter must be a valid ip address')
  }

  if ($type != 'A') and ($type != 'CNAME') {
    fail ('type must be A|CNAME')
  }

  $address_param = $string_check ? {
    ''      => '',
    default => "-a ${string_check}"
  }

  nrpe::check{ "dig_${name}":
    binaryname  => 'check_dig',
    params      => "-l ${record} -H ${dns_host} -T ${type} ${address_param}"
  }
}
