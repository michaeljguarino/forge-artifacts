locals {
  policy_arns = concat([aws_iam_policy.external_secrets.arn], var.extra_policy_arns)
}
