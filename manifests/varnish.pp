# Check per varnish customizzati per ogni istanza
# 3/2/2012 lorello
# TODO: no, non mi convince, la chiamata dal modulo varnish dovrebbe essere qualcosa di piu' generico, 
# fatta cosi' tanto valeva averla nel modulo varnish
# dovrebbe avere qualcosa del tipo nrpe::check_procs($name, $command, $args)
# dove $name è l'id univoco da dare al check (check_procs_$name), $command e $args sono 
# i parametri da dare al check per funzionare.
#
define nrpe::varnish {

    $configfile = "/etc/nagios/conf.d/varnish.cfg"

    # check processo varnish istanza
    softec::lib::line { "nrpe-varnish-add-${name}-check":
        ensure  => present,
        file    => "${configfile}",
        line    => "command[check_varnish_${name}]=/usr/lib/nagios/plugins/check_procs -w 2:2 -c 2:2 -C varnishd -a \"-P /var/run/varnishd-${name}.pid -n ${name}\"",
    }

    # check processo varnishncsa istanza
    softec::lib::line { "nrpe-varnishncsa-add-${name}-check":
        ensure  => present,
        file    => "${configfile}",
        #nota: il nome del pidfile contiene un errore nello script di init originale del pacchetto vers.3.0.2-1~1lucid1!
        #line    => "command[check_varnishncsa_${name}]=/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -C varnishncsa -a \"-a -w /var/log/varnish/varnishncsa-${name}.log -D -P /var/run/varnishncsa-${name}/varnishncsa-${name}.pid} -n ${name}\"",
        line    => "command[check_varnishncsa_${name}]=/usr/lib/nagios/plugins/check_procs -w 1:1 -c 1:1 -C varnishncsa -a \"-a -c -w /var/log/varnish/varnishncsa-${name}.log -D -P /var/run/varnishncsa-${name}/varnishncsa-${name}.pid -n ${name}\"",
    }

    # check cache misses (check_generic+varnishstat)
    softec::lib::line { "nrpe-varnishstat-add-${name}-cache-misses-check":
        ensure  => present,
        file    => "${configfile}",
        line    => "command[check_varnishstat_${name}_cache_misses]=/usr/lib/nagios/plugins/contrib/check_generic -e \"varnishstat -n ${name} -1 -f cache_miss | awk '\\''{ print \\\$3 }'\\''\" -w \">5\" -c \">15\" -n \"${name} cache_misses\" -p cache_misses",
    }

    # check backend fails (check_generic+varnishstat)
    softec::lib::line { "nrpe-varnishstat-add-${name}-backend-fail-check":
        ensure  => present,
        file    => "${configfile}",
        line    => "command[check_varnishstat_${name}_backend_fail]=/usr/lib/nagios/plugins/contrib/check_generic -e \"varnishstat -n ${name} -1 -f backend_fail | awk '\\''{ print \\\$3 }'\\''\" -w \">5\" -c \">15\" -n \"${name} backend fail\" -p backend_fail --type DELTA",
    }
}
