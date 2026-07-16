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

# A FIFO queue for an ordered, exactly-once payments pipeline: SSE-KMS with a
# customer-managed key, a dead-letter queue after 5 failed receives, and a
# queue policy that grants a producer and a consumer role access while denying
# any non-TLS request.
module "sqs" {
  source = "../.."

  # Queue name composes to: dvtca-prod-payments.fifo
  namespace = "dvtca"
  stage     = "prod"
  name      = "payments"

  fifo_queue = true

  # Customer-managed KMS key instead of the SQS-managed SSE default.
  kms_master_key_id = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 1209600 # 14 days
  delay_seconds              = 5

  # Dead-letter queue after 5 failed receives.
  max_receive_count = 5

  # Producer (CI/service role) and consumer (worker role) get Send/Receive; all
  # non-TLS access is denied by the generated policy.
  policy_principals = [
    "arn:aws:iam::111122223333:role/payments-producer",
    "arn:aws:iam::444455556666:role/payments-consumer",
  ]

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-sqs"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-sqs"
  }
}
