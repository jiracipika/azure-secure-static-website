# 01 — Secure Static Website

**Azure Cloud Engineering Portfolio · Project 1 of 10**

**Visibility:** PUBLIC · **Status:** implementation scaffold, no Azure resources deployed

## Goal

Build a secure static website using Azure Front Door Premium, Web Application Firewall, Azure Storage static website, private-origin connectivity, HTTPS, a custom domain, and GitHub Actions with federated identity.

This portfolio exercise emphasizes architecture, least privilege, cost awareness, validation, and repeatable cleanup—not merely drawing a diagram.

## For GLM in ZCode

1. Read `AGENTS.md`, `docs/GLM_TASKS.md`, and `docs/ARCHITECTURE.md`.
2. Audit the existing files and verify the current Azure documentation before implementing.
3. Implement the next safe, offline-testable milestone, write automated tests, and keep documentation synchronized.
4. **Do not deploy billable Azure resources or run `terraform apply` without explicit owner approval.**
5. Commit working code and report real test results, failures, and next actions.

## Planned components

Azure DNS / custom domain → Azure Front Door Premium + WAF → Private Link → Azure Storage static website.

GitHub Actions uses short-lived OpenID Connect credentials, but private Storage upload needs a secure, reachable deployment path; do not assume a public runner can write to a completely private endpoint.

## First milestone

Build an accessible static site and deterministic offline architecture tests. Terraform scaffolding and GitHub CI must be safe by default. See `docs/GLM_TASKS.md` for the exact handoff and acceptance tests.

**This repository is the only public one.** Projects 2–10 must remain private. No secrets, customer information, cloud credentials, private Terraform state, or copied Instagram screenshots belong here.
