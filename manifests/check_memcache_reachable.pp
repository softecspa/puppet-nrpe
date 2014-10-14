define nrpe::check_memcache_reachable (
  $host_port  = '',
  $w          = '1',
  $c          = '2',
) {

  $real_host_port = $host_port? {
    ''      => $name,
    default => $host_port
  }

  $host = inline_template("<%= @real_host_port.split(':').at(0) %>")
  $port = inline_template("<%= @real_host_port.split(':').at(1) %>")

  nrpe::check{ "memcache_${host}_${port}":
    binaryname  => 'check_tcp',
    params      => "-H ${host} -p ${port} -w ${w} -c ${c}"
  }

}
