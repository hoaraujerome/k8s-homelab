#!/usr/bin/env bash

AWS_PROFILE="k8s_homelab_prereq"
TERRAFORM_SERVICE_ACCOUNT_NAME="k8s_homelab"

# Source the shared functions
CURRENT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_MODULES_DIR="$(cd "${CURRENT_SCRIPT_DIR}/.." && pwd)/modules/scripts"
source "${SCRIPTS_MODULES_DIR}/logging.sh"
source "${SCRIPTS_MODULES_DIR}/constants.sh"

create_terraform_backends() {
  log_message "Create Terraform Backends for Images and Cluster Infra"

  local buckets=("${PACKER_INFRA_BUCKET_NAME}" "${CLUSTER_INFRA_BUCKET_NAME}")

  for bucket in "${buckets[@]}"; do
    log_message "Creating backend bucket: ${bucket}"
    local output
    output=$(aws s3 mb "s3://${bucket}" --profile "${AWS_PROFILE}" 2>&1)
    local exit_code=$?

    if [ ${exit_code} -eq 0 ]; then
      log_message "Bucket ${bucket} created successfully"
    elif echo "${output}" | grep -q "BucketAlreadyOwnedByYou"; then
      log_message "Bucket ${bucket} already exists"
    else
      log_message "Error creating bucket ${bucket}: ${output}" >&2
      exit ${exit_code}
    fi
  done
}

create_iam_user() {
  local output
  output=$(aws iam create-user --user-name "${TERRAFORM_SERVICE_ACCOUNT_NAME}" --profile "${AWS_PROFILE}" 2>&1)
  local exit_code=$?
  if [ ${exit_code} -eq 0 ]; then
    log_message "IAM user ${TERRAFORM_SERVICE_ACCOUNT_NAME} created successfully"
  elif echo "${output}" | grep -q "EntityAlreadyExists"; then
    log_message "IAM user ${TERRAFORM_SERVICE_ACCOUNT_NAME} already exists"
  else
    log_message "error: ${output}" >&2
    exit ${exit_code}
  fi
}

create_iam_policy() {
  local output
  output=$(
    aws iam create-policy \
      --policy-name "${TERRAFORM_SERVICE_ACCOUNT_NAME}" \
      --policy-document "file://./foundations/${TERRAFORM_SERVICE_ACCOUNT_NAME}.json" \
      --profile "${AWS_PROFILE}" 2>&1
  )
  local exit_code=$?
  if [ ${exit_code} -eq 0 ]; then
    log_message "IAM policy ${TERRAFORM_SERVICE_ACCOUNT_NAME} created successfully"
  else
    log_message "error: ${output}" >&2
    exit ${exit_code}
  fi
}

attach_iam_user_to_policy() {
  local output
  output=$(
    aws iam list-policies \
      --query "Policies[?PolicyName=='${TERRAFORM_SERVICE_ACCOUNT_NAME}'].Arn" \
      --profile "${AWS_PROFILE}" 2>&1
  )
  local exit_code=$?
  if [ ${exit_code} -ne 0 ]; then
    log_message "error: ${output}" >&2
    exit ${exit_code}
  fi

  local policy_arn=$(
    echo ${output} | jq -r '.[0]'
  )
  log_message "${policy_arn}"

  output=$(
    aws iam attach-user-policy \
      --policy-arn "${policy_arn}" \
      --user-name "${TERRAFORM_SERVICE_ACCOUNT_NAME}" \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?
  if [ ${exit_code} -eq 0 ]; then
    log_message "IAM user attached to policy successfully"
  else
    log_message "error: ${output}" >&2
    exit ${exit_code}
  fi
}

create_terraform_service_account() {
  log_message "Create Terraform Service Account"
  create_iam_user
  create_iam_policy
  attach_iam_user_to_policy
}

main() {
  create_terraform_backends
  create_terraform_service_account
}

main
