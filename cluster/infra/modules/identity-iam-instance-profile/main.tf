locals {
  instance_profile_name = "${var.tag_prefix}${var.name}"
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.instance_profile_name
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_instance_profile" "this" {
  name = local.instance_profile_name
  role = aws_iam_role.this.name
}

data "aws_iam_policy_document" "permissions" {
  statement {
    effect = "Allow"

    actions   = var.actions
    resources = var.resources
  }
}

resource "aws_iam_policy" "permissions" {
  name   = "${local.instance_profile_name}-policy"
  policy = data.aws_iam_policy_document.permissions.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.permissions.arn
}
