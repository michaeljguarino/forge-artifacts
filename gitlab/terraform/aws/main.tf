resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "plural"
      "app.plural.sh/name" = "gitlab"
      "platform.plural.sh/sync-target" = "pg"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

module "assumable_role_gitlab" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.14.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-${var.role_name}"
  provider_url                  = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.gitlab.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.gitlab_serviceaccount}"]
}

module "assumable_role_gitlab_runner" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.14.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-${var.runner_role_name}"
  provider_url                  = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.gitlab_runner.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.runner_serviceaccount}"]
}

resource "aws_iam_policy" "gitlab" {
  name_prefix = "gitlab"
  description = "policy for the plural gitlab instance you've deployed"
  policy      = data.aws_iam_policy_document.gitlab.json
}

resource "aws_iam_policy" "gitlab_runner" {
  name_prefix = "gitlab-runner"
  description = "policy for the ci/cd runners for your gitlab instance"
  policy      = data.aws_iam_policy_document.gitlab_runner.json
}

resource "aws_s3_bucket" "registry" {
  bucket        = var.registry_bucket
  acl           = "private"
  force_destroy = var.force_destroy_registry_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "lfs" {
  bucket        = var.lfs_bucket
  acl           = "private"
  force_destroy = var.force_destroy_lfs_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = var.artifacts_bucket
  acl           = "private"
  force_destroy = var.force_destroy_artifacts_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "packages" {
  bucket        = var.packages_bucket
  acl           = "private"
  force_destroy = var.force_destroy_packages_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "backups" {
  bucket        = var.backups_bucket
  acl           = "private"
  force_destroy = var.force_destroy_backups_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "backups_tmp" {
  bucket        = var.backups_tmp_bucket
  acl           = "private"
  force_destroy = var.force_destroy_backups_tmp_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "uploads" {
  bucket        = var.uploads_bucket
  acl           = "private"
  force_destroy = var.force_destroy_uploads_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.terraform_bucket
  acl           = "private"
  force_destroy = var.force_destroy_terraform_state_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "runner_cache" {
  bucket        = var.runner_cache_bucket
  acl           = "private"
  force_destroy = var.force_destroy_runner_cache_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "gitlab" {
  statement {
    sid    = "admin"
    effect = "Allow"
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${var.registry_bucket}",
      "arn:aws:s3:::${var.registry_bucket}/*",
      "arn:aws:s3:::${var.lfs_bucket}",
      "arn:aws:s3:::${var.lfs_bucket}/*",
      "arn:aws:s3:::${var.artifacts_bucket}",
      "arn:aws:s3:::${var.artifacts_bucket}/*",
      "arn:aws:s3:::${var.packages_bucket}",
      "arn:aws:s3:::${var.packages_bucket}/*",
      "arn:aws:s3:::${var.backups_bucket}",
      "arn:aws:s3:::${var.backups_bucket}/*",
      "arn:aws:s3:::${var.backups_tmp_bucket}",
      "arn:aws:s3:::${var.backups_tmp_bucket}/*",
      "arn:aws:s3:::${var.uploads_bucket}",
      "arn:aws:s3:::${var.uploads_bucket}/*",
    ]
  }
}

data "aws_iam_policy_document" "gitlab_runner" {
  statement {
    sid    = "admin"
    effect = "Allow"
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${var.runner_cache_bucket}",
      "arn:aws:s3:::${var.runner_cache_bucket}/*"
    ]
  }
}

data "aws_iam_role" "postgres" {
  name = "${var.cluster_name}-postgres"
}

resource "kubernetes_service_account" "postgres" {
  metadata {
    name      = "postgres-pod"
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.postgres.arn
    }
  }

  depends_on = [
    kubernetes_namespace.gitlab
  ]
}