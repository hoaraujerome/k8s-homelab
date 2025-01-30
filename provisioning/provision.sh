#!/usr/bin/env bash

set -e

main() {
  terraform -chdir="./provisioning/main-account/ca-central-1/prod" init
  terraform -chdir="./provisioning/main-account/ca-central-1/prod" plan
  terraform -chdir="./provisioning/main-account/ca-central-1/prod" apply
}

main
