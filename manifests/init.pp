#
# This class is responsible for installing a test node for
# running the openstack tests
#
class openstack_test {

  class { 'vagrant': }

  class { 'squid3':
    maximum_object_size => '30096 KB',
    cache_dir           => 'ufs /var/spool/squid3/ 10000 256 1024',
  }

  package { 'puppet':
    provider => 'gem',
    ensure   => '2.7.20',
  }

  package { 'ruby-dev':
    ensure => present,
  }

  package { 'github_api':
    provider => 'gem',
    ensure   => present,
    require  => Package['ruby-dev'],
  }

  package { 'librarian-puppet':
    provider => 'gem',
    ensure   => present,
    require  => Package['puppet'],
  }

  # TODO - setup node as a jenkins slave

}
