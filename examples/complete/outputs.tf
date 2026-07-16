output "queue_url" {
  description = "URL of the main FIFO queue."
  value       = module.sqs.queue_url
}

output "queue_name" {
  description = "Name of the main FIFO queue (ends with .fifo)."
  value       = module.sqs.queue_name
}

output "dlq_url" {
  description = "URL of the dead-letter queue."
  value       = module.sqs.dlq_url
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue."
  value       = module.sqs.dlq_arn
}
