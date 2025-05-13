#!/usr/bin/env bash

AWS_PROFILE="k8s_homelab_prereq"
BUCKET_NAME="hoaraujerome-k8s-homelab"
TERRAFORM_SERVICE_ACCOUNT_NAME="k8s_homelab"

# TODO to delete after migration to foundations
create_networking_for_packer() {
  echo "Create VPC for Packer"
  local output
  local exit_code
  output=$(
    aws ec2 create-vpc \
      --cidr-block 10.50.0.0/16 \
      --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=packer-vpc}]' \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  local vpc_id=$(
    echo ${output} | jq -r '.Vpc.VpcId'
  )
  echo "${vpc_id}"

  echo "Create Internet Gateway for Packer"
  output=$(
    aws ec2 create-internet-gateway \
      --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=packer-igw}]' \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  local igw_id=$(
    echo ${output} | jq -r '.InternetGateway.InternetGatewayId'
  )
  echo "${igw_id}"

  echo "Attach Internet Gateway to VPC for Packer"
  output=$(
    aws ec2 attach-internet-gateway \
      --internet-gateway-id "${igw_id}" \
      --vpc-id "${vpc_id}" \
      --profile "${AWS_PROFILE}" 2>&1
  )

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  echo "Create subnet for Packer"
  output=$(
    aws ec2 create-subnet \
      --vpc-id ${vpc_id} \
      --cidr-block 10.50.1.0/24 \
      --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=packer-subnet}]' \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  local subnet_id=$(
    echo ${output} | jq -r '.Subnet.SubnetId'
  )
  echo "${subnet_id}"

  echo "Create route table for Packer"
  output=$(
    aws ec2 create-route-table \
      --vpc-id ${vpc_id} \
      --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=packer-rt}]' \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  local rt_id=$(
    echo ${output} | jq -r '.RouteTable.RouteTableId'
  )
  echo "${rt_id}"

  echo "Create route for Packer"
  output=$(
    aws ec2 create-route \
      --route-table-id "${rt_id}" \
      --destination-cidr-block 0.0.0.0/0 \
      --gateway-id "${igw_id}" \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  echo "Associate route table for Packer"
  output=$(
    aws ec2 associate-route-table \
      --subnet-id "${subnet_id}" \
      --route-table-id "${rt_id}" \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi

  echo "Enable auto-assign public IPs on subnet"
  output=$(
    aws ec2 modify-subnet-attribute \
      --subnet-id ${subnet_id} \
      --map-public-ip-on-launch \
      --profile "${AWS_PROFILE}" 2>&1
  )
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    echo "$(basename $0) - error: ${output}" >&2
    exit ${exit_code}
  fi
}

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
  # create_networking_for_packer
  create_terraform_backend
  create_terraform_service_account
}

main
