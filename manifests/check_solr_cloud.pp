define nrpe::check_solr_cloud (
  $zookeeper_ensemble,
) {

  nrpe::check {"solr_cloud":
    binaryname  => 'check_solr_cloud.py',
    contrib     => true,
    params      => "-z $zookeeper_ensemble",
  }

  if !defined(Package['python-pip']) {
    package {'python-pip': ensure => present }
  }

  exec {'install_python_kazoo':
    command => '/usr/bin/pip install kazoo',
    unless  => '/usr/bin/pip freeze | grep kazoo'
  }
}
