output "s3_access_key" {
  value = aws_iam_access_key.pipelines.id
}

output "s3_access_secret" {
  value = aws_iam_access_key.pipelines.secret
}
