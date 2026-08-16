# Public reference configuration for GitHub Actions OIDC.
#
# This file intentionally uses placeholders and is NOT connected to a real
# AWS account. The privileged execution environment lives in the private lab.

variable "aws_region" {
  description = "AWS region used by the example"
  type        = string
  default     = "us-east-1"
}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    data.tls_certificate.github_actions.certificates[0].sha1_fingerprint,
  ]
}

# Educational example only. Replace the repository identifiers with your
# own values when implementing this pattern in a controlled environment.
resource "aws_iam_role" "github_actions_terraform" {
  name                 = "github-actions-terraform"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubActionsOIDCEnvironmentGate"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            # Use immutable repository/environment claims in a real setup.
            "token.actions.githubusercontent.com:sub" = "repo:<OWNER>@<OWNER_ID>/<REPO>@<REPO_ID>:environment:aws-plan"
          }
        }
      }
    ]
  })
}

# Example least-privilege read policy. Keep Plan and Apply identities
# separate in a production implementation.
resource "aws_iam_role_policy" "terraform_plan_read_only" {
  name = "terraform-plan-read-only"
  role = aws_iam_role.github_actions_terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformPlanExampleReadOnly"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketTagging",
          "s3:ListBucket",
        ]
        Resource = "arn:aws:s3:::<EXAMPLE_BUCKET_NAME>"
      }
    ]
  })
}

# In the private lab, Apply permissions and the apply environment are kept
# separate from the public project. Do not reuse a Plan role as an Apply role
# in a production design.
