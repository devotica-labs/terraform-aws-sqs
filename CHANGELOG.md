# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: an Amazon SQS queue (standard or FIFO) with fintech-safe
  defaults — server-side encryption always on (SQS-managed SSE by default,
  SSE-KMS via `kms_master_key_id`), an optional dead-letter queue created when
  `max_receive_count > 0` (redrive policy on the main queue + redrive-allow
  policy on the DLQ), and an optional queue access policy driven by
  `policy_principals` that grants Send/Receive and denies non-TLS requests.
  Native `label.tf` naming; built natively from the AWS provider.
