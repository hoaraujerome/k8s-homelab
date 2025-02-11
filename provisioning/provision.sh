#!/usr/bin/env bash

set -e

AWS_PROFILE="k8s_homelab"
MODULES_PATH="./provisioning/modules"
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
  terraform fmt -check -diff -recursive
}

test_modules() {
  log_message "Test modules"

  for dir in ./provisioning/modules/*/; do
    log_message "... module: ${dir}"
    pushd "${dir}"
    terraform init -backend=false
    terraform validate
    terraform test
    popd
  done
}

setup_terraform_vars() {
  export TF_VAR_ssh_public_key_path="${HOME}/.ssh/id_rsa_k8s_homelab.pub"
}

run_terraform_plan() {
  log_message "Run Terraform plan"

  pushd "${ROOT_MODULE_PATH}"
  terraform init -backend=false
  terraform validate
  setup_terraform_vars
  terraform init
  terraform plan -out="${TFPLAN_FILENAME}"
  popd
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

  if [ -z "${SKIP_TESTS}" ]; then
    test_modules
  fi

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
