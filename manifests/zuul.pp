class openstack_test::zuul(
  $jenkins_apikey,
  $zuul_ssh_private_key,
  $vhost_name     = $::fqdn,
  $jenkins_user   = 'jenkins_user',
  $jenkins_server = 'http://localhost:8080',
  $gerrit_server  = 'review.openstack.org',
  $gerrit_user    = 'puppet-openstack-ci-user'
) {
  class { '::zuul':
    vhost_name           => $vhost_name,
    serveradmin          => "root@localhost",
    jenkins_server       => $jenkins_server,
    jenkins_user         => $jenkins_user,
    jenkins_apikey       => $jenkins_apikey,
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    zuul_ssh_private_key => $zuul_ssh_private_key,
    # I need to figure out what these do
    #url_pattern => '',
    #status_url => "https://${::fqdn}/",
    git_source_repo      => 'https://github.com/openstack-infra/zuul.git',
    push_change_refs     => false,
  }
  file { '/etc/zuul/layout.yaml':
    source => 'puppet:///modules/openstack_test/layout.conf',
  }
  file { '/etc/zuul/logging.conf':
    ensure => present,
    source => 'puppet:///modules/openstack_test/zuul/logging.conf',
    notify => Exec['zuul-reload'],
  }
}
