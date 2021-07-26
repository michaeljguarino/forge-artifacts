resource "kubernetes_namespace" "crossplane" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "plural"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

module "assumable_role_crossplane" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.14.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-${var.role_name}"
  provider_url                  = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.crossplane.arn]
  oidc_subjects_with_wildcards = ["system:serviceaccount:${var.namespace}:*"]
}

resource "aws_iam_policy" "crossplane" {
  name_prefix = "crossplane"
  description = "policy for crossplane"
  policy      = data.aws_iam_policy_document.crossplane.json
}

data "aws_iam_policy_document" "crossplane" {
  statement {
    sid    = "admin"
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}
