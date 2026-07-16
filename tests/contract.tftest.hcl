# Contract tests — naming + default delivery/encryption settings stay stable
# across versions.

mock_provider "aws" {}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "contract"
}

run "queue_named_from_label" {
  command = plan
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.name]) == "dvtca-test-contract"
    error_message = "Queue name must compose namespace-stage-name."
  }
}

run "default_visibility_timeout_is_30" {
  command = plan
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.visibility_timeout_seconds]) == 30
    error_message = "Default visibility timeout must be 30 seconds."
  }
}

run "default_retention_is_four_days" {
  command = plan
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.message_retention_seconds]) == 345600
    error_message = "Default message retention must be 4 days (345600s)."
  }
}

run "sse_managed_default_true" {
  command = plan
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.sqs_managed_sse_enabled]) == true
    error_message = "SQS-managed SSE must default to true."
  }
}
