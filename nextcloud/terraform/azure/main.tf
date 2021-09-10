resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "nextcloud"
    }
  }
}

terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = ">= 1.0.0"
    }
  }
  required_version = ">= 0.13"
}

provider "minio" {
  minio_server = var.minio_server
  minio_region = var.minio_region
  minio_access_key = var.minio_access_key
  minio_secret_key = var.minio_secret_key
  minio_ssl = "true"
}

resource "minio_s3_bucket" "nextcloud" {
  bucket = var.nextcloud_bucket
}

data "minio_iam_policy_document" "nextcloud" {
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
resource "minio_iam_policy" "nextcloud" {
  name = "minio-nextcloud"
  policy    = data.minio_iam_policy_document.nextcloud.json

}

resource "minio_iam_user" "nextcloud" {
  name = "nextcloud"
}

resource "minio_iam_user_policy_attachment" "nextcloud" {
  user_name      = minio_iam_user.nextcloud.id
  policy_name = minio_iam_policy.nextcloud.id
}

resource "kubernetes_secret" "nextcloud_s3_secret" {
  metadata {
    name = "nextcloud-s3-secret"
    namespace = kubernetes_namespace.nextcloud.id
  }
  data = {
    "username" = minio_iam_user.nextcloud.id
    "password" = minio_iam_user.nextcloud.secret
  }
}
