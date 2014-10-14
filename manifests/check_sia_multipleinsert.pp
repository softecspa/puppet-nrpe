define nrpe::check_sia_multipleinsert (
  $url        = '',
  $warn       = '0.1',
  $crit       = '5',
  $perf_tag   = 'query_time'
) {

  $sia_url = $url? {
    ''      => $name,
    default => $url,
  }

  nrpe::check {"sia_multipleinsert":
    binaryname  => 'check_generic',
    contrib     => true,
    params      => "-e \"wget -O - http://$sia_url\" -w '>$warn' -c '>$crit' -p $perf_tag",
  }
}
