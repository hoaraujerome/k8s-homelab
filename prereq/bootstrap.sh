#!/usr/bin/env bash

AWS_PROFILE="k8s_homelab_prereq"
BUCKET_NAME="hoaraujerome-k8s-homelab"
TERRAFORM_SERVICE_ACCOUNT_NAME="k8s_homelab"

# AWS_CLI_TAG="2.16.5"
# CURRENT_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# USER_POLICY_FILENAME="user_policy.json"
# KEY_FILE="$HOME/.ssh/id_rsa_k8s_the_hard_way"
# K8S_CRYPTO_ASSETS_DIRECTORY="$HOME/.k8s_the_hard_way"
#
# certs=(
#   "service-accounts"
#   "kube-api-server"
#   "kube-controller-manager"
#   "admin"
#   "kube-scheduler"
#   "node-0"
#   "kube-proxy"
# )
#
# setup_ssh_key() {
#   ssh-keygen -t rsa -b 2048 -f "$KEY_FILE" -N ""
# }
#
# setup_root_ca() {
#   mkdir -p ${K8S_CRYPTO_ASSETS_DIRECTORY}
#
#   pushd "${K8S_CRYPTO_ASSETS_DIRECTORY}"
#   openssl genrsa -out ca.key 4096
#   openssl req -x509 -new -sha512 -noenc \
#     -key ca.key -days 365 \
#     -config ${CURRENT_SCRIPT_DIRECTORY}/ca.conf \
#     -out ca.crt
#   popd
# }
#
# setup_k8s_certs() {
#   pushd "${K8S_CRYPTO_ASSETS_DIRECTORY}"
#   for i in ${certs[*]}; do
#     openssl genrsa -out "${i}.key" 4096
#
#     openssl req -new -key "${i}.key" -sha256 \
#       -config "${CURRENT_SCRIPT_DIRECTORY}/ca.conf" -section ${i} \
#       -out "${i}.csr"
#
#     openssl x509 -req -days 365 -in "${i}.csr" \
#       -copy_extensions copyall \
#       -sha256 -CA "ca.crt" \
#       -CAkey "ca.key" \
#       -CAcreateserial \
#       -out "${i}.crt"
#   done
#   popd
# }
#
# setup_crypto_assets() {
#   setup_ssh_key
#   setup_root_ca
#   setup_k8s_certs
# }
#
# run_aws_command() {
#   docker run \
#     --rm \
#     -it \
#     -v ~/.aws:/root/.aws:ro \
#     -v ${CURRENT_SCRIPT_DIRECTORY}/user_policy.json:/aws/${USER_POLICY_FILENAME}:ro \
#     amazon/aws-cli:${AWS_CLI_TAG} \
#     ${@} --profile ${AWS_PROFILE}
# }

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
