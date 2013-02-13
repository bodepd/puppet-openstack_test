#!/bin/bash
# super simple script for deploying an openstack environment from script
# to invoke, run:
#   > bash -c "$(curl -fsS https://raw.github.com/bodepd/puppet-openstack_test/master/install.sh)"
#
# this is just here b/c librarian puppet cannot be installed as a gem if puppet is installed from
# apt
if dpkg-query --show puppet ; then
  echo 'Puppet is currently installed from apt, being uninstalled and reinstalled from gem (BEWARE)';
  apt-get remove -y puppet
fi
if dpkg-query --show facter ; then
  echo 'facter is currently installed from apt, being uninstalled and reinstalled from gem (BEWARE)';
  apt-get remove -y facter
fi
apt-get install -y rubygems
gem install puppet -v 2.7.20
apt-get install -y git-core
git clone https://github.com/bodepd/puppet-vagrant /etc/puppet/modules/vagrant
git clone https://github.com/bodepd/puppet-squid3 /etc/puppet/modules/squid3
git clone https://github.com/bodepd/puppet-openstack_test /etc/puppet/modules/openstack_test
git clone https://github.com/puppetlabs/puppetlabs-stdlib /etc/puppet/modules/stdlib
git clone https://github.com/puppetlabs/puppetlabs-apt /etc/puppet/modules/apt
puppet apply -e 'include openstack_test'
