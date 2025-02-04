#!/usr/bin/env bash

set -e

AWS_PROFILE="k8s_homelab"
ROOT_MODULE_PATH="./provisioning/main-account/ca-central-1/prod"

log_message() {
  local message="${1}"
  echo "$(basename ${0}) - ${message}"
}

print_usage() {
  echo "Usage: $(basename ${0}) <plan|deploy|destroy>"
  exit 1
}

check_terraform_files() {
  pre-commit run terraform_fmt --all-files
  pre-commit run terraform_validate --all-files
}

plan() {
  log_message "Plan infrastructure provisioning"
  check_terraform_files

  terraform -chdir="${ROOT_MODULE_PATH}" init
  terraform -chdir="${ROOT_MODULE_PATH}" plan
}

deploy() {
  log_message "Deploy infrastructure"
  check_terraform_files
  local tfplan_filename="tfplan"

  terraform -chdir="${ROOT_MODULE_PATH}" init
  terraform -chdir="${ROOT_MODULE_PATH}" plan -out="${tfplan_filename}"
  terraform -chdir="${ROOT_MODULE_PATH}" apply "${tfplan_filename}"
}

destroy() {
  log_message "Destroy infrastructure"
  check_terraform_files

  terraform -chdir="${ROOT_MODULE_PATH}" init
  terraform -chdir="${ROOT_MODULE_PATH}" destroy
}

main() {
  local argument="${1}"
  if [ -z "${argument}" ]; then
    print_usage
  fi

  export AWS_PROFILE="${AWS_PROFILE}"

  case "${argument}" in
  plan)
    plan
    ;;
  deploy)
    deploy
    ;;
  destroy)
    destroy
    ;;
  *)
    echo "$(basename ${0}) - invalid argument: ${argument}" >&2
    print_usage
    ;;
  esac
}

main "${1}"
