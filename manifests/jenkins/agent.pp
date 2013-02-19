class openstack_test::jenkins::agent (
  $server,
  $ssh_password,
  $jenkins_password = 'jenkins_password',
) {
  jenkins::agent { $::hostname:
    server       => $server,
    port         => 8080,
    username     => 'jenkins_user',
    # this password is also not being set...
    password     => $jenkins_password,
    executors    => 1,
    launcher     => 'ssh',
    homedir      => '/home/jenkins',
    ssh_user     => 'jenkins',
    ssh_password => $ssh_password,
    labels       => 'auto-installed by puppet',
    create_user  => true,
  }
}
