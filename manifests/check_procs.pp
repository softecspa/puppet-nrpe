# == Class: nrpe::check_procs
#
# Check process existence
#
# === Parameters:
#
# I parametri ricalcano gli stessi del plugin
#
# ===Todo:
#
# check for metric in PROCS, VSZ, RSS, CPU, ELAPSED
#
define nrpe::check_procs(
  $crit             = undef,
  $warn             = undef,
  $metric           = 'PROCS',
  $command          = undef,
  $argument_array   = undef,
  $procs_owner      = undef,
  $procs_ppid       = undef,
  $state            = undef,
  )
{

  $procs_owner_arg = $procs_owner ? {
    undef   =>  '',
    default =>  "-u '${procs_owner}'",
  }

  $argument_array_arg = $argument_array ? {
    undef   =>  '',
    default =>  "--argument-array='${argument_array}'",
  }

  $command_arg = $command ? {
    undef   =>  '',
    default =>  "--command='${command}'",
  }

  if $procs_ppid != undef {
    if ! is_numeric($procs_ppid) {
      fail('procs_ppid argument must be numeric')
    }
  }
  $procs_ppid_arg = $procs_ppid ? {
    undef   =>  '',
    default =>  "--ppid=${procs_ppid}",
  }

  $warn_arg = $warn ? {
    undef   =>  '',
    default =>  "--warning=${warn}",
  }

  $crit_arg = $crit ? {
    undef   =>  '',
    default =>  "--critical=${crit}",
  }

  $state_arg = $state ? {
    undef   => '',
    default => "-s=$state",
  }

  nrpe::check{ "proc_${name}":
    binaryname  => 'check_procs',
    params      => "--metric=$metric ${warn_arg} ${crit_arg} ${command_arg} ${argument_array_arg} ${procs_owner_arg} ${state_arg}"
  }
}
