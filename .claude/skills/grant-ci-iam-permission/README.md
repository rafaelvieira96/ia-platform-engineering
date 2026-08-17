# GitHub Actions OIDC + IAM Permission Skill

This lab demonstrates two related Platform Engineering concepts:

1. GitHub Actions authenticating to AWS with **OIDC**, without long-lived AWS credentials.
2. Claude Code using a reusable **IAM permission skill** to research and document the permissions required by Terraform-managed resources.

---

## 1. GitHub Actions OIDC with Terraform

The basic architecture is:

```text
GitHub Actions
      |
      | OIDC token
      v
GitHub OIDC Provider
      |
      v
AWS IAM Role
      |
      v
AWS resources
```

The OIDC provider can be represented with Terraform:

```hcl
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
```

The IAM role then trusts the GitHub OIDC provider:

```hcl
resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions.arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"

          "token.actions.githubusercontent.com:sub" =
            "repo:<OWNER>@<OWNER_ID>/<REPO>@<REPO_ID>:environment:<ENVIRONMENT>"
        }
      }
    }]
  })
}
```

Use repository and environment restrictions in the trust policy. Do not trust every repository or every GitHub Actions workflow.

The workflow can then request short-lived credentials:

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - name: Configure AWS Credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: ${{ vars.AWS_ROLE_ARN }}
      aws-region: us-east-1
```

The important security property is that GitHub does not need a long-lived AWS access key or secret key stored as a GitHub secret.

> **Public repository note:** The examples above are intentionally generic. Replace placeholders only in an appropriately protected environment. This public lab does not provide a privileged Apply workflow.

---

## 2. Using the Claude IAM Permission Skill

The skill is located at:

```text
.claude/skills/grant-ci-iam-permission/SKILL.md
```

It helps Claude determine what IAM permissions a CI role needs when a new Terraform resource is introduced.

For example, after adding an SQS resource:

```text
Use the grant-ci-iam-permission skill to determine the minimum IAM
permissions required for aws_sqs_queue.
```

The skill guides Claude through:

```text
Terraform resource
       |
       v
Provider documentation
       |
       v
AWS API calls used by Read()
       |
       v
IAM actions
       |
       v
Resource scope
       |
       v
Least-privilege policy
       |
       v
Human review
```

### The important rule

> **Do not guess IAM permissions.**

Claude should research the Terraform provider behavior and determine which AWS API operations are actually required.

---

## 3. Plan vs Apply permissions

The skill distinguishes between permissions required for Terraform plan and apply.

### Terraform plan

Usually requires read-only operations such as:

```text
Read / Describe / List
```

### Terraform apply

Usually requires lifecycle operations such as:

```text
Create
Read
Update
Delete
Tag
Untag
```

The exact permissions depend on the Terraform resource.

The public repository intentionally does not provide a privileged Apply path. Real IAM changes and cloud execution belong in the private laboratory environment.

---

## 4. Why this matters

These pieces are part of the larger Platform Engineering experiment:

```text
Developer intent
       |
       v
     Agent
       |
       +---- MCP
       |
       +---- Skills
       |
       v
Platform automation
       |
       +---- GitHub
       +---- Terraform
       +---- CI/CD
       +---- AWS
       |
       v
Governance + IAM + approvals
```

The objective is not simply to let an AI execute infrastructure.

The objective is to give the agent **well-defined capabilities, tools, permissions and guardrails** so that it can safely orchestrate platform operations.
