define nrpe::check_memcache (
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

  if !defined(Package['libcache-memcached-perl']) { 
    package {'libcache-memcached-perl':
      ensure => present,
    }
  }

  nrpe::check{ "memcache_${host}_${port}":
    binary_name => 'check_memcached.pl',
    params      => "-H ${host} -p ${port} -T'>1,>2' -R '<40,<30' -U '>95,>98'"
  }

}
