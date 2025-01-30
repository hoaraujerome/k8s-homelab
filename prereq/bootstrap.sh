#!/usr/bin/env bash

AWS_PROFILE="k8s_homelab_prereq"
BUCKET_NAME="hoaraujerome-k8s-homelab"
TERRAFORM_SERVICE_ACCOUNT_NAME="k8s_homelab"

create_terraform_backend() {
  echo "Create Terraform Backend"

  local output
  output=$(aws s3 mb "s3://${BUCKET_NAME}" --profile "${AWS_PROFILE}" 2>&1)
  local exit_code=$?

  if [ ${exit_code} -eq 0 ]; then
    echo "Bucket ${BUCKET_NAME} created successfully"
  elif echo "${output}" | grep -q "BucketAlreadyOwnedByYou"; then
    echo "Bucket ${BUCKET_NAME} already exists"
  else
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi
}

create_iam_user() {
  local output
  output=$(aws iam create-user --user-name "${TERRAFORM_SERVICE_ACCOUNT_NAME}" --profile "${AWS_PROFILE}" 2>&1)
  local exit_code=$?
  if [ ${exit_code} -eq 0 ]; then
    echo "IAM user ${TERRAFORM_SERVICE_ACCOUNT_NAME} created successfully"
  elif echo "${output}" | grep -q "EntityAlreadyExists"; then
    echo "IAM user ${TERRAFORM_SERVICE_ACCOUNT_NAME} already exists"
  else
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi
}

create_iam_policy() {
  local output
  output=$(
    aws iam create-policy \
      --policy-name "${TERRAFORM_SERVICE_ACCOUNT_NAME}" \
      --policy-document "file://./prereq/${TERRAFORM_SERVICE_ACCOUNT_NAME}.json" \
      --profile "${AWS_PROFILE}" 2>&1
  )
  local exit_code=$?
  if [ ${exit_code} -eq 0 ]; then
    echo "IAM policy ${TERRAFORM_SERVICE_ACCOUNT_NAME} created successfully"
  else
    echo "$(basename $0) - error: ${output}" >&2
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
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  local policy_arn=$(
    echo ${output} | jq -r '.[0]'
  )
  echo "${policy_arn}"

  output=$(
    aws iam attach-user-policy \
      --policy-arn "${policy_arn}" \
      --user-name "${TERRAFORM_SERVICE_ACCOUNT_NAME}" \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?
  if [ ${exit_code} -eq 0 ]; then
    echo "IAM user attached to policy successfully"
  else
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi
}

create_terraform_service_account() {
  echo "Create Terraform Service Account"
  create_iam_user
  create_iam_policy
  attach_iam_user_to_policy
}

main() {
  create_terraform_backend
  create_terraform_service_account
}

main
