locals {
  # FIFO queues require the literal `.fifo` name suffix.
  queue_name = var.fifo_queue ? "${local.id}.fifo" : local.id
  dlq_name   = var.fifo_queue ? "${local.id}-dlq.fifo" : "${local.id}-dlq"

  # A dead-letter queue is created only when a redrive threshold is set.
  create_dlq = local.enabled && var.max_receive_count > 0

  # SQS-managed SSE (SSE-SQS) is on unless a KMS key is supplied — the two SSE
  # modes are mutually exclusive on a queue.
  sse_managed = var.kms_master_key_id == null

  # A queue policy is attached only when principals are granted access.
  need_policy = local.enabled && length(var.policy_principals) > 0
}
