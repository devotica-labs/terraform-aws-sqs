output "queue_url" {
  description = "URL of the main SQS queue (the send/receive endpoint)."
  value       = try(aws_sqs_queue.this[0].id, null)
}

output "queue_arn" {
  description = "ARN of the main SQS queue."
  value       = try(aws_sqs_queue.this[0].arn, null)
}

output "queue_name" {
  description = "Name of the main SQS queue (includes the .fifo suffix for FIFO queues)."
  value       = try(aws_sqs_queue.this[0].name, null)
}

output "dlq_url" {
  description = "URL of the dead-letter queue, or null when no DLQ is created."
  value       = try(aws_sqs_queue.dlq[0].id, null)
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue, or null when no DLQ is created."
  value       = try(aws_sqs_queue.dlq[0].arn, null)
}
