# Security Policy

## Credentials
Never commit API keys, access tokens, private keys, cookies, or model-provider credentials. Use environment variables or GitHub Actions secrets.

## Model integrity
Model artifacts should be obtained from a trusted build source and verified with SHA-256 before production loading.

## Privacy
The core engine is designed for local/offline execution and does not require network access. Any network adapter must be explicit, opt-in, and isolated from the core runtime.

## Reporting
For security issues, open a private GitHub security advisory when available. Do not publish exploitable details in a public issue.
