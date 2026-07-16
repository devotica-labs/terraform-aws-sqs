# Main SQS queue. Fintech defaults: server-side encryption is always on —
# SQS-managed SSE by default, or SSE-KMS when kms_master_key_id is supplied
# (the two are mutually exclusive). TLS is enforced via the queue policy.
resource "aws_sqs_queue" "this" {
  count = local.enabled ? 1 : 0

  name = local.queue_name

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds              = var.delay_seconds

  # Encryption — exactly one mode is active.
  # Exactly one SSE mode may be set — null (not false) disables SQS-managed SSE
  # so it doesn't conflict with kms_master_key_id.
  sqs_managed_sse_enabled = local.sse_managed ? true : null
  kms_master_key_id       = var.kms_master_key_id

  # Move messages to the DLQ after max_receive_count failed receives.
  redrive_policy = local.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = local.tags
}

# Dead-letter queue — same type/encryption as the source queue. Created only
# when max_receive_count > 0.
resource "aws_sqs_queue" "dlq" {
  count = local.create_dlq ? 1 : 0

  name = local.dlq_name

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue

  message_retention_seconds = var.message_retention_seconds

  # Exactly one SSE mode may be set — null (not false) disables SQS-managed SSE
  # so it doesn't conflict with kms_master_key_id.
  sqs_managed_sse_enabled = local.sse_managed ? true : null
  kms_master_key_id       = var.kms_master_key_id

  tags = local.tags
}

# Allow only the source queue to redrive into the DLQ.
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  count = local.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this[0].arn]
  })
}

# Queue access policy — grants SendMessage/ReceiveMessage to policy_principals
# and denies any non-TLS request. Attached only when principals are supplied.
resource "aws_sqs_queue_policy" "this" {
  count = local.need_policy ? 1 : 0

  queue_url = aws_sqs_queue.this[0].id
  policy    = data.aws_iam_policy_document.queue[0].json
}
