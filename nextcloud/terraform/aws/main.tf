resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "nextcloud"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

module "assumable_role_nextcloud" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.14.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-${var.role_name}"
  provider_url                  = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.nextcloud.arn]
  oidc_subjects_with_wildcards = [
    "system:serviceaccount:*:${var.nextcloud_serviceaccount}"
  ]
}

resource "aws_iam_access_key" "nextcloud" {
  user    = aws_iam_user.nextcloud.name
}

# create iam user(s) with full s3 permissions
resource "aws_iam_user" "nextcloud" {
  name          = "nextcloud"
  force_destroy = true
}

resource "aws_iam_user_policy_attachment" "attach_s3_full_access" {
  user       = aws_iam_user.nextcloud.name
  policy_arn = aws_iam_policy.nextcloud.arn
}

resource "aws_iam_policy" "nextcloud" {
  name_prefix = "nextcloud"
  description = "policy for nextcloud resources"
  policy      = data.aws_iam_policy_document.nextcloud.json
}

resource "kubernetes_secret" "nextcloud_s3_secret" {
  metadata {
    name = "nextcloud-s3-secret"
    namespace = kubernetes_namespace.nextcloud.id
  }
  data = {
    "username" = aws_iam_access_key.nextcloud.id
    "password" = aws_iam_access_key.nextcloud.secret
  }
}

resource "aws_s3_bucket" "nextcloud" {
  bucket = var.nextcloud_bucket
  acl    = "private"
}

data "aws_iam_policy_document" "nextcloud" {
  statement {
    sid    = "admin"
    effect = "Allow"
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${var.nextcloud_bucket}",
      "arn:aws:s3:::${var.nextcloud_bucket}/*"
    ]
  }
}
