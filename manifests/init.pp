#
# This class is responsible for installing a test node for
# running the openstack tests
#
class openstack_test {

  class { 'vagrant': }

  class { 'squid3':
    maximum_object_size => '30096 KB',
    cache_dir           => 'ufs /var/spool/squid/ 10000 256 1024',
  }

  package { ['github_api', 'librarian-puppet']:
    provider => 'gem',
    ensure   => present,
  }

  # TODO - setup node as a jenkins slave

}
