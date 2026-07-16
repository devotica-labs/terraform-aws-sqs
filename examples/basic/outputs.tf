output "queue_url" {
  description = "URL of the main queue."
  value       = module.sqs.queue_url
}

output "queue_arn" {
  description = "ARN of the main queue."
  value       = module.sqs.queue_arn
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue."
  value       = module.sqs.dlq_arn
}
