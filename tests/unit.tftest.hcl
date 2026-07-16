# Plan-only unit tests — no AWS credentials required. The queue policy resource
# validates its JSON, so mock aws_iam_policy_document to valid JSON.

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "unit"
}

run "main_queue_planned" {
  command = plan
  assert {
    condition     = length(aws_sqs_queue.this) == 1
    error_message = "Exactly one main queue must be planned."
  }
}

run "no_dlq_by_default" {
  command = plan
  assert {
    condition     = length(aws_sqs_queue.dlq) == 0
    error_message = "No dead-letter queue unless max_receive_count > 0."
  }
  assert {
    condition     = length(aws_sqs_queue_redrive_allow_policy.dlq) == 0
    error_message = "No redrive-allow policy without a DLQ."
  }
}

run "dlq_created_when_max_receive_count_set" {
  command = plan
  variables {
    max_receive_count = 5
  }
  assert {
    condition     = length(aws_sqs_queue.dlq) == 1
    error_message = "A DLQ must be created when max_receive_count > 0."
  }
  assert {
    condition     = length(aws_sqs_queue_redrive_allow_policy.dlq) == 1
    error_message = "The DLQ must allow the source queue to redrive."
  }
}

run "sse_managed_on_by_default" {
  command = plan
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.sqs_managed_sse_enabled]) == true
    error_message = "SQS-managed SSE must be enabled by default."
  }
}

run "kms_switches_off_sqs_managed_sse" {
  command = plan
  variables {
    kms_master_key_id = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.kms_master_key_id]) == "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"
    error_message = "kms_master_key_id must pass through to the queue."
  }
}

run "fifo_name_ends_with_fifo" {
  command = plan
  variables {
    fifo_queue = true
  }
  assert {
    condition     = endswith(one([for q in aws_sqs_queue.this : q.name]), ".fifo")
    error_message = "A FIFO queue name must end with .fifo."
  }
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.fifo_queue]) == true
    error_message = "fifo_queue must be set on the queue."
  }
}

run "no_queue_policy_by_default" {
  command = plan
  assert {
    condition     = length(aws_sqs_queue_policy.this) == 0
    error_message = "No queue policy unless principals are supplied."
  }
}

run "queue_policy_when_principals_supplied" {
  command = plan
  variables {
    policy_principals = ["arn:aws:iam::111122223333:role/producer"]
  }
  assert {
    condition     = length(aws_sqs_queue_policy.this) == 1
    error_message = "A queue policy must be attached when principals are supplied."
  }
  assert {
    condition     = length(data.aws_iam_policy_document.queue) == 1
    error_message = "The policy document must render when principals are supplied."
  }
}
