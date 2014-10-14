define nrpe::check_tomcat_fd (
  $ok='',
  $crit='',
  $warn='',
  $timeout='',
  $nfiles,
) {

  $ok_threshold = $ok ? {
    ''      => inline_template('<%= nfiles.to_i-500%>'),
    default => $ok,
  }

  $w_threshold = $warn ? {
    ''      => inline_template('<%= nfiles.to_i-250 %>'),
    default => $warn,
  }

  $c_threshold = $crit ? {
    ''      => inline_template('<%= nfiles.to_i-501 %>'),
    default => $crit,
  }

  $t_timeout = $timeout ? {
    ''      => $timeout,
    default => " -t $timeout",
  }

  nrpe::check {'tomcat_fd':
    binaryname  => 'check_generic',
    contrib     => true,
    params      => "-e \"sudo lsof -c jsvc -c java | wc -l\" -fUNKNOWN -o \"<${ok_threshold}\" -c \">${c_threshold}\" -w \">${w_threshold}\" ${t_timeout}",
  }

  # TODO: eliminare, serve solo ad eliminare i vecchi file
  file {'/etc/nagios/conf.d/tomcat.cfg':
    ensure  => absent
  }

}
