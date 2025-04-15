#!/usr/bin/env bash

set -e

AWS_PROFILE="k8s_homelab"
CONFIGURATION_PATH="./image-building/packer"

log_message() {
  local message="${1}"
  echo "$(basename ${0}) - ${message}"
}

setup_environment() {
  export AWS_PROFILE="${AWS_PROFILE}"
}

init() {
  log_message "Initialize Packer Configuration"
  packer init .
}

format() {
  log_message "Format template files"
  packer fmt .
}

validate() {
  log_message "Validate template files"
  packer validate .
}

build() {
  log_message "Build image"
  packer build aws-ubuntu.pkr.hcl
}

main() {
  setup_environment

  pushd "${CONFIGURATION_PATH}"
  init
  format
  validate
  build
  popd
}

main
