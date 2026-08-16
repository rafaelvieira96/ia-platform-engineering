# AI Platform Engineering Lab

This repository is the public companion to my hands-on exploration of **AI Agents + Platform Engineering**.

The goal is to explore how an AI agent can understand developer intent and orchestrate platform capabilities while keeping the existing engineering controls in place.

Example:

> "I need a Java application stack for development."

The longer-term goal is for the platform to orchestrate the repository, CI/CD, infrastructure, Kubernetes, Helm, Argo CD, cloud resources and permissions according to predefined platform standards.

## Architecture direction

```text
Developer intent
       |
       v
   AI Agent
       |
       +---- Skills / MCP tools
       |
       v
 Platform automation
       |
       +---- GitHub
       +---- Terraform
       +---- CI/CD
       +---- Cloud
       |
       v
 Governance / approvals / least privilege
```

## What's in this repository

This public repository focuses on the architecture, experiments and lessons learned. It intentionally does **not** contain production credentials, real AWS account identifiers, privileged Apply workflows, or live infrastructure state.

The private laboratory repository contains the real execution environment used during the experiments.

## Status

Early-stage experiment. The project is evolving incrementally, starting with MCP, Terraform, GitHub Actions, OIDC and IAM, and moving toward agent-driven platform orchestration.

## Disclaimer

This is an experimental learning project. The examples are intentionally simplified and should be reviewed and adapted before use in a production environment.
