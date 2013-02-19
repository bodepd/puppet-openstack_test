class openstack_test::jenkins::server {
  jenkins::server { 'space_chipmunk':
    setup_auth => true,
  }
}
