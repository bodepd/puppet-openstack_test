#
# This class is responsible for installing a test node for
# running the openstack tests
#
class openstack_test(
  $base_dir = '/home/jenkins',
) {

  class { 'vagrant': }

  class { 'squid3':
    maximum_object_size => '30096 KB',
    cache_dir           => 'ufs /var/spool/squid3/ 10000 256 1024',
  }

  file_line { 'localnet_acl':
    line  => 'acl localnet src 172.16.0.0/16',
    path  => '/etc/squid3/squid.conf',
  }

  file_line { 'localnet_http_access':
    line    => 'http_access allow localnet',
    path    => '/etc/squid3/squid.conf',
    require => File_line['localnet_acl'],
  }

  package { 'bundler':
    ensure   => present,
    provider => 'gem'
  }

}
