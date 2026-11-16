# GLM backlog — Secure Static Website

## Immediate milestone
1. Confirm the provided architecture and its security flaws.
2. Build offline runnable topology or Terraform modules; keep deploy_enabled=false.
3. Write test cases proving: Build a responsive accessible website and test HTTPS, WAF, private origin and safe deployment network.
4. Validate terraform fmt/init -backend=false/validate and unittest; capture real output in VALIDATION.md.
5. Refine Mermaid diagram and README to match code.
6. Prepare live deployment pricing, identities and teardown for explicit owner review.

## Design caveat
Private Storage cannot be uploaded to from an arbitrary GitHub-hosted runner; choose a trusted deployment path.

No live Azure resources are authorized. Do not stop after planning: build/test locally.
