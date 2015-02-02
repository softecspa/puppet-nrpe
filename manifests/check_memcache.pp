define nrpe::check_memcache (
  $host_port    = '',
  $warn_rtime   = '>1',
  $crit_rtime   = '>2',
  $warn_hitrate = '<10',
  $crit_hitrate = '<8',
  $warn_usage   = '>95',
  $crit_usage   = '>98',
) {

  $real_host_port = $host_port? {
    ''      => $name,
    default => $host_port
  }

  $host = inline_template("<%= @real_host_port.split(':').at(0) %>")
  $port = inline_template("<%= @real_host_port.split(':').at(1) %>")

  if !defined(Package['libcache-memcached-perl']) {
    package {'libcache-memcached-perl':
      ensure => present,
    }
  }

  $thresholds_rtime   = "\'${warn_rtime},${crit_rtime}\'"
  $thresholds_hitrate = "\'${warn_hitrate},${crit_hitrate}\'"
  $thresholds_usage   = "\'${warn_usage},${crit_usage}\'"

  nrpe::check{ "memcache_${host}_${port}":
    contrib    => true,
    binaryname => 'check_memcached.pl',
    params     => "-H ${host} -p ${port} -T ${thresholds_rtime} -R ${thresholds_hitrate} -U ${thresholds_usage}"
  }

}
