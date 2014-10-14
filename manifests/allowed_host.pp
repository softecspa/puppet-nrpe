define nrpe::allowed_host (
  $allowed_hosts,
) {

  class {'nrpe':
    allowed_hosts  => $allowed_hosts
  }

}
