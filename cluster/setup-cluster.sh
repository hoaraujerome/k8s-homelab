#!/usr/bin/env bash

set -e

AWS_PROFILE="k8s_homelab"
CLUSTER_PATH="./cluster"
CLUSTER_INFRA_PATH="${CLUSTER_PATH}/infra"
ROOT_MODULE_PATH="${CLUSTER_INFRA_PATH}/main-account/ca-central-1/prod"
TFPLAN_FILENAME="tfplan"
COMMON_CHILD_MODULES_PATH="./modules/infra"
CLUSTER_CHILD_MODULES_PATH="${CLUSTER_INFRA_PATH}/modules"
CHILD_MODULES_DIRS=(
  "${COMMON_CHILD_MODULES_PATH}"/*/
  "${CLUSTER_CHILD_MODULES_PATH}"/*/
)

# Source the shared functions
CURRENT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_MODULES_DIR="$(cd "${CURRENT_SCRIPT_DIR}/.." && pwd)/modules/scripts"
source "${SCRIPTS_MODULES_DIR}/logging.sh"
source "${SCRIPTS_MODULES_DIR}/security-scanner.sh"

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

  for dir in "${CHILD_MODULES_DIRS[@]}"; do
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

plan_infra() {
  log_message "Plan infrastructure"

  check_terraform_files

  if [ -z "${SKIP_TESTS}" ]; then
    test_modules
  fi

  run_terraform_plan
  run_security_scanner "${COMMON_CHILD_MODULES_PATH}" "${CLUSTER_CHILD_MODULES_PATH}" "${ROOT_MODULE_PATH}"
}

run_terraform_apply() {
  log_message "Run Terraform apply"

  terraform -chdir="${ROOT_MODULE_PATH}" apply "${TFPLAN_FILENAME}"
}

deploy_infra() {
  log_message "Deploy infrastructure"

  plan_infra
  run_terraform_apply
}

destroy_infra() {
  log_message "Destroy infrastructure"

  check_terraform_files
  setup_terraform_vars
  pushd "${ROOT_MODULE_PATH}"
  terraform init
  terraform destroy
  popd
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
    plan_infra
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
