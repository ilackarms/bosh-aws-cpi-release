#!/usr/bin/env bash

set -e -x

source bosh-cpi-release/ci/tasks/utils.sh

check_param base_os
check_param aws_access_key_id
check_param aws_secret_access_key

source /etc/profile.d/chruby.sh
chruby 2.1.2

cpi_release_name=bosh-aws-cpi
semver=`cat version-semver/number`
manifest_dir=bosh-concourse-ci/pipelines/$cpi_release_name
manifest_filename=${manifest_dir}/${base_os}-director-manifest.yml

terraform_statefile_semver=`cat terraform-state-version/number`
source terraform-${base_os}-exports/terraform-${base_os}-exports-${terraform_statefile_semver}.sh

# leave this for now, it will be heredoc'ed in future
./bosh-concourse-ci/tasks/generate-manifest.rb ${manifest_filename}

echo "normalizing paths to match values referenced in $manifest_filename"
mkdir ./tmp
cp ./bosh-cpi-dev-artifacts/${cpi_release_name}-${semver}.tgz ./tmp/${cpi_release_name}.tgz
cp ./bosh-release/release.tgz ./tmp/bosh-release.tgz
cp ./stemcell/stemcell.tgz ./tmp/stemcell.tgz
cp ./bosh-concourse-ci/pipelines/bosh-aws-cpi/bats.pem ./tmp/bats.pem

initver=$(cat bosh-init/version)
initexe="$PWD/bosh-init/bosh-init-${initver}-linux-amd64"
chmod +x $initexe
chmod 400 ./tmp/bats.pem

echo "using bosh-init CLI version..."
$initexe version

echo "deleting existing BOSH Director VM..."
$initexe delete $manifest_filename

echo "deploying BOSH..."
$initexe deploy $manifest_filename
