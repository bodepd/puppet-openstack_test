class openstack_test::server(
  $jenkins_user        = 'jenkins_user',
  $jenkins_password    = 'jenkins_password',
  $create_default_jobs = true
) {

  package { 'git':
    ensure => present,
  }

  jenkins::server { 'space_chipmunk':
    setup_auth => true,
  }

  jenkins::plugin { 'gearman-plugin':
    version => '0.0.3',
  }

  class { 'jenkins::job_builder':
    url      => 'http://127.0.0.1:8080',
    username => $jenkins_user,
    password => $jenkins_password,
    require  => Package['git']
  }

  if($create_default_jobs) {
    class { 'openstack_test::openstack_jenkins_job': }
  }

}
