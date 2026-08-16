---
name: grant-ci-iam-permission
description: >-
  Guides Claude Code through researching and documenting the minimum IAM
  permissions needed by a CI role for an AWS resource type. The workflow
  emphasizes provider research, explicit scope, least privilege and human
  approval for privileged changes.
version: 1
---

# Grant CI Role IAM Permission

Use this skill when a CI workflow needs additional AWS permissions for a
Terraform-managed resource type.

This skill is intentionally written for a public Platform Engineering lab.
It describes the engineering workflow without containing real account IDs,
roles, credentials or production infrastructure details.

## 1. Identify the resource

Map the request to the specific Terraform AWS provider resource type.

Examples:

- SQS → `aws_sqs_queue`
- DynamoDB → `aws_dynamodb_table`
- Lambda → `aws_lambda_function`

If multiple resource types are plausible, ask which one is intended.

## 2. Research the required API calls

Do not guess IAM permissions from memory.

Use the Terraform provider documentation, provider source code, Terraform MCP
provider tools, or authoritative AWS documentation to determine which AWS API
calls the resource `Read()` operation performs.

Map those API calls to IAM actions and document the reasoning briefly.

Also check whether the resource has related or self-referential resources that
Terraform will refresh during `plan`.

## 3. Confirm the permission scope

Before changing IAM, explicitly distinguish between:

- **Read-only** — permissions required for Terraform refresh/plan.
- **Read + CRUD** — permissions required to manage the resource lifecycle with
  Terraform apply.
- **Custom** — a specifically requested subset or extension.

Never silently broaden a read-only request into write access.

Never add destructive-adjacent actions or service-wide wildcards unless the
user explicitly requests them.

## 4. Scope resources as narrowly as practical

Prefer resource-specific ARNs instead of `Resource = "*"`.

For public examples, use placeholders or Terraform expressions rather than
committing real account IDs or environment-specific ARNs.

Example:

```hcl
arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:<queue-prefix>*
```

If the target resource does not exist yet, confirm the intended naming pattern
before documenting a resource-scoped policy.

## 5. Document the IAM change

When adding a policy example, keep read and write statements separate and use
clear Sids.

Add a short comment explaining why the action list is required.

Prefer a reusable local for large, well-defined action lists.

## 6. Validate before privileged execution

For Terraform examples:

1. Run `terraform fmt`.
2. Run `terraform validate`.
3. Review the planned IAM diff.
4. Require explicit human approval before applying privileged changes.
5. Verify the resulting policy independently when appropriate.

This public repository does not provide a privileged Apply path. Actual IAM
changes belong in the private execution environment.

## 7. Git workflow

Changes to this skill should:

1. Use a descriptive branch name.
2. Review the complete diff before committing.
3. Ensure no secrets, account IDs, ARNs or state files are included.
4. Keep privileged execution separate from the public documentation repo.

Do not automatically push or merge changes unless explicitly requested.

## Out of scope

- Creating real AWS resources.
- Applying IAM policies to a real AWS account from this public repository.
- Adding privileged GitHub Actions workflows.
- Storing credentials or environment-specific identifiers.
