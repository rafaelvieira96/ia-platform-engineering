# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## What this repository is

This is a public, hands-on lab for exploring how AI agents can interact with DevOps and Platform Engineering tooling. The lab focuses on the separation between the AI agent, MCP tools, infrastructure-as-code, CI/CD and cloud APIs.

The longer-term direction is an AI-driven Internal Developer Platform (IDP) where a developer can express intent such as:

> "I need a Java application stack for development."

and platform automation can orchestrate the required repository, CI/CD, infrastructure, Kubernetes, Helm, Argo CD and cloud capabilities according to predefined standards.

## Public repository guard-rails

This repository is intentionally sanitized for public use.

- Never add real cloud account IDs, ARNs, credentials, tokens or secrets.
- Never commit Terraform state, provider credentials, `.tfvars`, backend configuration containing environment-specific values, or generated `.terraform/` content.
- Use placeholders such as `<AWS_ACCOUNT_ID>` when an architecture example needs an account identifier.
- Do not add a privileged cloud Apply workflow to this public repository.
- Keep examples focused on architecture, learning and reproducible concepts rather than access to a real environment.

## Working principles

1. Do not skip conceptual steps in the lab.
2. Understand the mechanism before automating it.
3. Prefer read-only operations whenever possible.
4. Keep Agent, MCP, tools, Terraform and cloud APIs conceptually separate.
5. Destructive changes require explicit human supervision.
6. Document discoveries, problems and decisions as the lab progresses.

## MCP and Terraform

The lab distinguishes between an MCP server that provides documentation/tooling context and the Terraform CLI that actually executes Terraform operations.

Conceptually:

```text
                  Claude
                    |
           +--------+--------+
           |                 |
      Terraform MCP     Terraform CLI
           |                 |
           v                 v
   Terraform Registry    AWS Provider
                             |
                             v
                            AWS
```

The MCP layer should not be assumed to be the Terraform execution engine. Terraform `plan`, `apply`, `validate` and related operations are performed by the Terraform CLI when explicitly configured to do so.

## GitHub Actions

The public workflow is intentionally plan-only. It is designed to demonstrate CI/CD concepts without granting the public repository privileged access to a real cloud account.

Changes to workflows must preserve this property unless the project scope is explicitly changed.

## Claude skills

Reusable Claude Code skills are kept under `.claude/skills/`. A skill should document its purpose, prerequisites, workflow, safety boundaries and expected verification steps.

When creating or changing a skill:

- Make the scope explicit.
- Do not silently broaden permissions or operational scope.
- Require human confirmation for privileged or destructive operations.
- Prefer research-backed provider/API information over guessed permissions.
- Keep cloud-specific examples generic enough for this public repository.
