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

  package { ['libxslt-dev', 'libxml2-dev', 'ruby-dev']:
    ensure => present,
    before => Package['github_api'],
  }

  package { 'github_api':
    provider => 'gem',
    ensure   => present,
  }

  package { 'librarian-puppet':
    provider => 'gem',
    ensure   => present,
  }

  # TODO - setup node as a jenkins slave

}
