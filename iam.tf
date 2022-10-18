module "policy-s3-full-access" {
  source  = "mineiros-io/iam-policy/aws"
  version = "~> 0.5.0"

  name = "S3FullAccess"

  policy_statements = [
    {
      sid = "S3FullAccess"

      effect    = "Allow"
      actions   = ["s3:*"]
      resources = ["*"]
    }
  ]
}
