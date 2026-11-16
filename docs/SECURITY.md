# Security requirements

No secrets, state, privileged tokens, public SSH/RDP or customer data in git. Pin or review CI dependencies, scope federated identity, apply least privilege, block unauthorized network paths and log denial tests. Critical risk: Private Storage cannot be uploaded to from an arbitrary GitHub-hosted runner; choose a trusted deployment path.
