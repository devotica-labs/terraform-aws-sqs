# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/sqs/aws"
#   version = "~> 0.1"

module "sqs" {
  source = "../.."

  # Queue name composes to: dvtca-sandbox-events
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "events"

  # A standard queue with SQS-managed SSE (fintech default) and a dead-letter
  # queue that captures messages after 5 failed receives. Visibility timeout
  # (30s) and retention (4 days) come from the module defaults.
  max_receive_count = 5

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-sqs"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-sqs"
  }
}
