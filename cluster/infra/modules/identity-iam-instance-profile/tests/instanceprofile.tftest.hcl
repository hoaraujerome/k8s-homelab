run "setup_provider" {
  module {
    source = "../../../../modules/tests/setup/aws_provider"
  }
}

run "check_instance_profile" {
  variables {
    name       = "myrole"
    tag_prefix = "prefix-"
    actions    = ["ssm:PutParameter"]
    resources  = ["arn:aws:ssm:ca-central-1:YYY:parameter/foo1/*", "arn:aws:ssm:ca-central-1:XXX:parameter/foo2/*"]
  }

  command = plan

  assert {
    condition     = data.aws_iam_policy_document.ec2_trust.statement[0].effect == "Allow"
    error_message = "Invalid EC2 trust policy statement effect"
  }

  assert {
    condition = length([
      for p in data.aws_iam_policy_document.ec2_trust.statement[0].principals : p
      if p.type == "Service" && contains(p.identifiers, "ec2.amazonaws.com")
    ]) > 0

    error_message = "EC2 trust policy is missing a Service principal with ec2.amazonaws.com"
  }

  assert {
    condition = (
      length(data.aws_iam_policy_document.ec2_trust.statement[0].actions) == 1 &&
      contains(data.aws_iam_policy_document.ec2_trust.statement[0].actions, "sts:AssumeRole")
    )

    error_message = "EC2 Trust policy must include exactly one action: sts:AssumeRole"
  }

  assert {
    condition = aws_iam_role.this.name == "${var.tag_prefix}${var.name}"

    error_message = "Invalid IAM role name"
  }

  assert {
    condition = jsondecode(aws_iam_role.this.assume_role_policy) == jsondecode(data.aws_iam_policy_document.ec2_trust.json)

    error_message = "Invalid IAM assume role policy"
  }

  assert {
    condition = aws_iam_instance_profile.this.name == "${var.tag_prefix}${var.name}"

    error_message = "Invalid IAM instance profile name"
  }

  assert {
    condition = aws_iam_instance_profile.this.role == aws_iam_role.this.name

    error_message = "Invalid IAM instance profile role"
  }

  assert {
    condition     = data.aws_iam_policy_document.permissions.statement[0].effect == "Allow"
    error_message = "Invalid permissions policy statement effect"
  }

  assert {
    condition = alltrue([
      for a in var.actions : contains(data.aws_iam_policy_document.permissions.statement[0].actions, a)
    ]) && length(data.aws_iam_policy_document.permissions.statement[0].actions) == length(var.actions)

    error_message = "Permissions policy actions do not exactly match the expected actions list."
  }

  assert {
    condition = alltrue([
      for a in var.resources : contains(data.aws_iam_policy_document.permissions.statement[0].resources, a)
    ]) && length(data.aws_iam_policy_document.permissions.statement[0].resources) == length(var.resources)

    error_message = "Permissions policy resources do not exactly match the expected resources list."
  }

  assert {
    condition = aws_iam_policy.permissions.name == "${var.tag_prefix}${var.name}-policy"

    error_message = "Invalid IAM permissions policy name"
  }

  assert {
    condition = jsondecode(aws_iam_policy.permissions.policy) == jsondecode(data.aws_iam_policy_document.permissions.json)

    error_message = "Invalid IAM permissions policy"
  }

  assert {
    condition = aws_iam_role_policy_attachment.this.role == aws_iam_role.this.name

    error_message = "Invalid IAM role policy attachement role"
  }
}

run "create_instance_profile" {
  variables {
    name       = "myrole"
    tag_prefix = "prefix-"
    actions    = ["ssm:PutParameter", "ssm:GetParameter"]
    resources  = ["*"]
  }

  command = apply

  assert {
    condition = aws_iam_role_policy_attachment.this.policy_arn == aws_iam_policy.permissions.arn

    error_message = "Invalid IAM role policy attachement policy ARN"
  }

  assert {
    condition     = output.name == aws_iam_instance_profile.this.name
    error_message = "Invalid ouput name"
  }
}
