#!/usr/bin/env bash

set -e -x

source bosh-cpi-release/ci/tasks/utils.sh

check_param BOSH_AWS_ACCESS_KEY_ID
check_param BOSH_AWS_SECRET_ACCESS_KEY
check_param BOSH_AWS_SUBNET_ID
check_param BOSH_AWS_SUBNET_ZONE
check_param BOSH_AWS_LIFECYCLE_MANUAL_IP
check_param BOSH_AWS_DEFAULT_KEY_NAME

export BOSH_CLI_SILENCE_SLOW_LOAD_WARNING=true

source /etc/profile.d/chruby.sh
chruby 2.1.6

cd bosh-src/bosh_aws_cpi

bundle install
bundle exec rake spec:lifecycle
