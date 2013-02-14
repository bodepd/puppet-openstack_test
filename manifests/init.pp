#
# This class is responsible for installing a test node for
# running the openstack tests
#
class openstack_test(
  $github_user_login,
  $github_user_password,
) {

  class { 'vagrant': }

  class { 'squid3':
    maximum_object_size => '30096 KB',
    cache_dir           => 'ufs /var/spool/squid3/ 10000 256 1024',
  }

  file_line { 'localnet_acl':
    line  => 'acl localnet src 172.16.0.0/16',
    path  => '/etc/squid3/squid.conf',
    match => "^(#|)\s*acl\s"
  }

  file_line { 'localnet_http_access':
    line  => 'http_access allow localnet',
    path  => '/etc/squid3/squid.conf',
  }

  package { ['libxslt-dev', 'libxml2-dev', 'ruby-dev']:
    ensure => present,
    before => Package['github_api'],
  }

  package { 'github_api':
    provider => 'gem',
    ensure   => '0.8.1',
  }

  package { ['librarian', 'rspec']:
    provider => 'gem',
    ensure   => present,
  }

  package { 'librarian-puppet':
    provider => 'gem',
    ensure   => present,
    require  => Package['librarian'],
  }

  # TODO - setup node as a jenkins slave

  file { ['/etc/vagrant', '/etc/vagrant/projects']:
    ensure => directory,
    before => Vcsrepo['/etc/vagrant/projects/puppetlabs-openstack_dev_env'],
  }

  vcsrepo { '/etc/vagrant/projects/puppetlabs-openstack_dev_env':
    ensure => present,
    provider => git,
    source => 'https://github.com/puppetlabs/puppetlabs-openstack_dev_env',
  }

  file { "/etc/vagrant/projects/puppetlabs-openstack_dev_env/.github_auth":
    content => inline_template(
"login: <%= github_user_login %>
password: <%= github_user_password %>"),
    require => Vcsrepo['/etc/vagrant/projects/puppetlabs-openstack_dev_env']
  }
}
