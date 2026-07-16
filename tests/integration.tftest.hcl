# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# A standard queue plus its DLQ is cheap and fast to create/destroy, and both
# tear down cleanly (SQS queues carry no deletion protection).

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace         = "dvtca"
  stage             = "integ"
  name              = "sqs"
  max_receive_count = 5

  tags = {
    Environment = "integration-test"
    Ephemeral   = "true"
  }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = one([for q in aws_sqs_queue.this : q.arn]) != ""
    error_message = "Main queue must be created with an ARN."
  }
  assert {
    condition     = one([for q in aws_sqs_queue.this : q.url]) != ""
    error_message = "Main queue must expose a URL."
  }
  assert {
    condition     = length(aws_sqs_queue.dlq) == 1
    error_message = "The DLQ must apply cleanly against the real API."
  }
}
