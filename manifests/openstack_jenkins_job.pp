#
# installs a basic jenkins job that can be used to test all varieties of things openstack related
#
class openstack_test::openstack_jenkins_job() {

  Class['openstack_test::server'] -> Class['openstack_test::openstack_jenkins_job']

  file { '/etc/jenkins_jobs/config/openstack_unit_test.yml':
    content =>
"
- job-template:
    name: 'puppet-{repo}-{puppet_version}-unit'
    project-type: freestyle
    defaults: global
    disabled: false
    concurrent: true
    quiet-period: 0
    block-downstream: false
    block-upstream: false
    builders:
      - shell: |
          export PUPPET_GEM_VERSION='~> {puppet_version}'
          bundle install
          echo {puppet_version} | grep '2.6' && git clone git://github.com/puppetlabs/puppetlabs-create_resources.git spec/fixtures/modules/create_resources || true
          bundle exec rake spec SPEC_OPTS='--format documentation'
- job-group:
    name: 'puppet-module-unit'
    puppet_version:
      - 2.6
      - 2.7
      - 3.0
      - 3.1
    repo:
      - glance
      - keystone
      - cinder
      - nova
      - horizon
      - openstack
      - swift
    jobs:
      - 'puppet-{repo}-{puppet_version}-unit'
- project:
    name: puppet-module-unit
    jobs:
      - puppet-module-unit
",
    notify  => Exec['jenkins_jobs_update'],
    require => [Exec['install_jenkins_job_builder'], Class['jenkins::service']],
  }

#?  file { "/etc/jenkins_jobs/config/openstack_test.yml":
#?    content =>
#?"- job:
#?    'puppet-{repo}-{puppet_version}-unit'
#?    name: openstack_test
#?    project-type: freestyle
#?    defaults: global
#?    disabled: false
#?    concurrent: true
#?    quiet-period: 0
#?    block-downstream: false
#?    block-upstream: false
#?    builders:
#?      - shell: |
#?          export module_install_method=librarian
#?          mkdir \$BUILD_ID
#?          cd \$BUILD_ID
#?          git clone git://github.com/puppetlabs/puppetlabs-openstack_dev_env
#?          cd puppetlabs-openstack_dev_env
#?          bash -e test_scripts/openstack_test.sh
#?    parameters:
#?      - choice:
#?          name: operatingsystem
#?          default: redhat
#?          description: \"Operatingsystem that openstack should be installed on. Accepts redhat,ubuntu. Defaults to Redhat.\"
#?          choices:
#?            - redhat
#?            - ubuntu
#?      - choice:
#?          name: openstack_version
#?          default: folsom
#?          description: \"Version of openstack that we should build. Accepts folsom or grizzly. Defaults to folsom (atm)\"
#?          choices:
#?            - folsom
#?            - grizzly
#?      - choice:
#?          name: test_mode
#?          default: unit
#?          description: \"The type of integration test that should be run. Accepts puppet_openstack, tempest_smoke, and tempest_full\"
#?          choices:
#?            - unit
#?            - tempest_smoke
#?            - puppet_openstack
#?            - tempest_full
#?      - choice:
#?          name: module_install_method
#?          default: librarian
#?          description: \"The method used to install the openstack modules. NOTE: \"
#?          choices:
#?            - librarian
#?            - pmt
#?
#?",
#?    notify  => Exec['jenkins_jobs_update'],
#?    require => Exec['install_jenkins_job_builder', 'reload_account_config'],
#?  }
  file { "/etc/jenkins_jobs/config/openstack_test.yml":
    content =>
'- defaults:
    name: global
    zuul-url: http://127.0.0.1:8001/jenkins_endpoint
- job:
    name : gate-puppet-dev-env
    project-type: freestyle
    defaults: global
    disabled: false
    concurrent: true
    quiet-period: 0
    block-downstream: false
    block-upstream: false
    builders:
      - shell: |
          #!/bin/bash
          set -x
          set -e
          set -u

          export module_install_method="librarian"
          export operatingsystem="ubuntu"
          export openstack_version="grizzly"
          export test_mode="puppet_openstack"
          export ref=`echo $ZUUL_CHANGES | awk -F":" \'{print $3}\'`
          export cherry_pick_command="git fetch https://review.openstack.org/$ZUUL_PROJECT $ref && git cherry-pick FETCH_HEAD"

          # get the name of the directory where we need to change code
          project=`echo $ZUUL_PROJECT | sed -e "s/stackforge\/puppet-//g"`
          export module_repo="modules/${project}"

          mkdir $BUILD_ID
          cd $BUILD_ID
          git clone "git://github.com/stackforge/puppet-openstack_dev_env"
          cd puppet-openstack_dev_env
          echo `pwd`
          export checkout_branch_command="${cherry_pick_command:-}"

          bash -xe test_scripts/openstack_test.sh
    triggers:
      - zuul
',
    notify  => Exec['jenkins_jobs_update'],
    require => [Exec['install_jenkins_job_builder'], Class['jenkins::service']],

  }

}
