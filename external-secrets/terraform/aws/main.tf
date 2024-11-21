resource "kubernetes_namespace" "external-secrets" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "external-secrets"

    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

module "assumable_role_external_secrets" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.14.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-${var.role_name}"
  provider_url                  = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = local.policy_arns
  oidc_subjects_with_wildcards = [
    "system:serviceaccount:${var.namespace}:${var.serviceaccount}",
  ]
}

resource "aws_iam_policy" "external_secrets" {
  name_prefix = var.role_name
  description = "policy for the plural admin console"
  policy      = data.aws_iam_policy_document.external_secrets.json
}

data "aws_iam_policy_document" "external_secrets" {
  statement {
    sid    = "admin"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.secret_prefix}"
    ]
  }
}
