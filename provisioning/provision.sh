#!/usr/bin/env bash

set -e

AWS_PROFILE="k8s_homelab"
ROOT_MODULE_PATH="./provisioning/main-account/ca-central-1/prod"
TFPLAN_FILENAME="tfplan"

log_message() {
  local message="${1}"
  echo "$(basename ${0}) - ${message}"
}

print_usage() {
  echo "Usage: $(basename ${0}) <plan|deploy|destroy>"
  exit 1
}

check_terraform_files() {
  log_message "Check Terraform files"

  pre-commit run terraform_fmt --all-files
  pre-commit run terraform_validate --all-files
}

run_terraform_plan() {
  log_message "Run Terraform plan"

  terraform -chdir="${ROOT_MODULE_PATH}" init
  terraform -chdir="${ROOT_MODULE_PATH}" plan -out="${TFPLAN_FILENAME}"
}

run_security_scanner() {
  log_message "Run security scanner"

  trivy fs \
    --scanners secret,misconfig \
    --exit-code 1 \
    "${PROVISIONING_PATH}"
}

plan_infra_provisioning() {
  log_message "Plan infrastructure provisioning"

  check_terraform_files
  run_terraform_plan
  run_security_scanner
}

run_terraform_apply() {
  log_message "Run Terraform apply"

  terraform -chdir="${ROOT_MODULE_PATH}" apply "${TFPLAN_FILENAME}"
}

deploy_infra() {
  log_message "Deploy infrastructure"

  plan_infra_provisioning
  run_terraform_apply
}

destroy_infra() {
  log_message "Destroy infrastructure"

  check_terraform_files
  terraform -chdir="${ROOT_MODULE_PATH}" init
  terraform -chdir="${ROOT_MODULE_PATH}" destroy
}

setup_environment() {
  export AWS_PROFILE="${AWS_PROFILE}"
}

main() {
  local argument="${1}"
  if [ -z "${argument}" ]; then
    print_usage
  fi

  setup_environment

  case "${argument}" in
  plan)
    plan_infra_provisioning
    ;;
  deploy)
    deploy_infra
    ;;
  destroy)
    destroy_infra
    ;;
  *)
    echo "$(basename ${0}) - invalid argument: ${argument}" >&2
    print_usage
    ;;
  esac
}

main "${1}"
