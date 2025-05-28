#!/usr/bin/env bash

set -e

AWS_PROFILE="k8s_homelab"
INFRA_MODULES_PATH="./modules/infra"
IMAGES_PATH="./images"
IMAGES_INFRA_PATH="${IMAGES_PATH}/infra"
ROOT_MODULE_PATH="${IMAGES_INFRA_PATH}/main-account/ca-central-1/prod"
TFPLAN_FILENAME="tfplan"
CONFIGURATION_PATH="${IMAGES_PATH}/config/packer"

# Source the shared functions
CURRENT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_MODULES_DIR="$(cd "${CURRENT_SCRIPT_DIR}/.." && pwd)/modules/scripts"
source "${SCRIPTS_MODULES_DIR}/logging.sh"
source "${SCRIPTS_MODULES_DIR}/constants.sh"
source "${SCRIPTS_MODULES_DIR}/security-scanner.sh"

print_usage() {
  echo "Usage: $(basename ${0}) <plan|deploy|build|destroy>"
  exit 1
}

check_terraform_files() {
  log_message "Check Terraform files"
  terraform fmt -check -diff -recursive
}

test_modules() {
  log_message "Test modules"

  for dir in ${INFRA_MODULES_PATH}/*/; do
    # if [[ "${dir}" == *vpc* ]]; then
    log_message "... module: ${dir}"
    pushd "${dir}"
    terraform init -backend=false
    terraform validate
    terraform test
    popd
    # fi
  done
}

run_terraform_init_with_s3_backend() {
  terraform init \
    -backend-config="bucket=${PACKER_INFRA_BUCKET_NAME}"
}

run_terraform_plan() {
  log_message "Run Terraform plan"

  pushd "${ROOT_MODULE_PATH}"
  terraform init -backend=false
  terraform validate
  run_terraform_init_with_s3_backend
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
  run_security_scanner "${IMAGES_PATH}" "${INFRA_MODULES_PATH}"
}

run_terraform_apply() {
  log_message "Run Terraform apply"

  terraform -chdir="${ROOT_MODULE_PATH}" apply "${TFPLAN_FILENAME}"
}

capture_vpc_and_subnet_ids() {
  log_message "Capture VPC and subnet IDs"

  local outputs=$(terraform -chdir="${ROOT_MODULE_PATH}" output -json)
  VPC_ID=$(echo "${outputs}" | jq -r '.packer_vpc_id.value')
  SUBNET_ID=$(echo "${outputs}" | jq -r '.packer_subnet_id.value')
}

deploy_infra() {
  log_message "Deploy infrastructure"

  plan_infra
  run_terraform_apply
  capture_vpc_and_subnet_ids
}

setup_packer_vars() {
  export PKR_VAR_vpc_id="${VPC_ID}"
  export PKR_VAR_subnet_id="${SUBNET_ID}"
}

run_packer_build() {
  log_message "Run Packer Build"

  pushd "${CONFIGURATION_PATH}"
  packer fmt -check -diff -recursive .
  setup_packer_vars
  echo $PKR_VAR_vpc_id
  packer init .
  packer validate .
  packer build aws-ubuntu.pkr.hcl
  popd
}

build_ami() {
  log_message "Build AMI"

  run_security_scanner "${CONFIGURATION_PATH}"
  run_packer_build
}

destroy_infra() {
  log_message "Destroy infrastructure"

  check_terraform_files
  pushd "${ROOT_MODULE_PATH}"
  run_terraform_init_with_s3_backend
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
  build)
    deploy_infra
    build_ami
    # destroy_infra
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
