define nrpe::check_varnish_instance (
  $instance_name='',
) {


  #TODO: eliminare serve solo a cancellare il file pushato dal vecchio modulo
  if !defined(File['/etc/nagios/conf.d/varnish.cfg']) {
    file {'/etc/nagios/conf.d/varnish.cfg':
      ensure  => absent
    }
  }

  $instance= $instance_name ? {
    ''      => $name,
    default => $instance_name
  }

  nrpe::check {"varnish_$instance":
    checkname   => "check_varnish_$instance",
    binaryname  => 'check_procs',
    params      => "-w 2:2 -c 2:2 -C varnishd -a \"-P /var/run/varnishd-${instance}.pid -n ${instance}\"",
  }

  if !defined(Softec_sudo::Conf['varnish_nagios']) {
    softec_sudo::conf {'varnish_nagios':
      source  => 'puppet:///modules/nrpe/etc/sudo_varnish'
    }
  }


  nrpe::check {"varnishncsa_$instance":
    checkname   => "check_varnishncsa_$instance",
    binaryname  => 'check_procs',
    params      => "-w 1:1 -c 1:1 -C varnishncsa -a \"-a -c -w /var/log/varnish/varnishncsa-${instance}.log -D -P /var/run/varnishncsa-${instance}/varnishncsa-${instance}.pid -n ${instance}\"",
  }

  nrpe::check {"varnishstat_${instance}_cache_misses":
    checkname   => "check_varnishstat_${instance}_cache_misses",
    binaryname  => 'check_generic',
    contrib     => true,
    #04/09/2014 asagratini, #1697, -w da 5 a 8 e -c da 15 a 18
    params      => "-e \"varnishstat -n ${instance} -1 -f cache_miss | awk '{ print \\\$3 }'\" -w \">8\" -c \">18\" -n \"${instance} cache_misses\" -p cache_misses",
  }

  nrpe::check {"varnishstat_${instance}_backend_fail":
    checkname   => "check_varnishstat_${instance}_backend_fail",
    binaryname  => 'check_generic',
    contrib     => true,
    params      => "-e \"varnishstat -n ${instance} -1 -f backend_fail | awk '{ print \\\$3 }'\" -w \">5\" -c \">15\" -n \"${instance} backend fail\" -p backend_fail --type DELTA",
  }

  nrpe::check{"varnish_${instance}_cache_hit_ratio":
    checkname   => "varnish_${instance}_cache_hit_ratio",
    binaryname  => 'check_varnish',
    contrib     => true,
    #04/09/2014 asagratini, #1697 -w da 0.8 a 0.7 e -c da 0.6 a 0.5
    params      => "-n ${instance} -a -w 0.7 -c 0.5",
  }

  nrpe::check{"varnish_${instance}_backends":
    checkname   => "varnish_${instance}_backends",
    binaryname  => 'check_varnish',
    contrib     => true,
    params      => "-n ${instance} -d all",
  }

  nrpe::check{"varnish_${instance}_client_drop_req":
    checkname   => "varnish_${instance}_client_drop_req",
    binaryname  => 'check_varnish',
    contrib     => true,
    params      => "-n ${instance} -s client_drop,client_req",
  }

  nrpe::check{"varnish_${instance}_n_lru_nuked_moved":
    checkname   => "varnish_${instance}_n_lru_nuked_moved",
    binaryname  => 'check_varnish',
    contrib     => true,
    params      => "-n ${instance} -s n_lru_nuked,n_lru_moved",
  }

}
