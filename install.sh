#!/bin/bash
# super simple script for deploying an openstack environment from script
# to invoke, run:
#   > bash -c "$(curl -fsS https://raw.github.com/bodepd/puppet-openstack_test/master/install.sh)"
#
# this is just here b/c librarian puppet cannot be installed as a gem if puppet is installed from
# apt

# install a few basic applications
apt-get install -y puppet rubygems git-core

git clone https://github.com/bodepd/puppet-vagrant /etc/puppet/modules/vagrant
git clone https://github.com/bodepd/puppet-squid3 /etc/puppet/modules/squid3
git clone https://github.com/bodepd/puppet-openstack_test /etc/puppet/modules/openstack_test
git clone https://github.com/puppetlabs/puppetlabs-stdlib /etc/puppet/modules/stdlib
git clone https://github.com/puppetlabs/puppetlabs-apt /etc/puppet/modules/apt
git clone https://github.com/puppetlabs/puppetlabs-vcsrepo /etc/puppet/modules/vcsrepo
git clone https://github.com/bodepd/puppet-jenkins /etc/puppet/modules/jenkins
git clone https://github.com/puppetlabs/puppetlabs-java /etc/puppet/modules/java

# conditionally install the stuff!
if [ -n "$install_test_env" ]; then

  if [ -z "$github_user_login" ]; then
    echo "ENV VAR github_user_login must be set"
    exit 1
  fi

  if [ -z "$github_user_password" ]; then
    echo "ENV VAR github_user_password must be set"
    exit 1
  fi

  puppet apply -e "class { 'openstack_test': github_user_login => $github_user_login, github_user_password => $github_user_password }"

fi

if [ -n "$install_jenkins_server" ]; then
  puppet apply -e "include 'openstack_test::jenkins::server'"
fi

if [ -n "$install_jenkins_agent" ]; then
  if [ -z "$jenkins_server" ]; then
    echo "ENV VAR jenkins_server must be set"
    exit 1
  fi

  if [ -z "$ssh_password" ]; then
    echo "ENV VAR ssh_password must be set"
    exit 1
  fi
  puppet apply -e "class { 'openstack_test::jenkins::agent': server => '$jenkins_server', ssh_password => '$ssh_password' }"
fi
