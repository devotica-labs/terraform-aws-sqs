# ---------------------------------------------------------------------------
# Queue type
# ---------------------------------------------------------------------------
variable "fifo_queue" {
  type        = bool
  description = "Create a FIFO queue (exactly-once, ordered) instead of a standard queue. When true the queue name gets the required `.fifo` suffix and content-based deduplication is enabled."
  default     = false
}

# ---------------------------------------------------------------------------
# Encryption (server-side)
# ---------------------------------------------------------------------------
variable "kms_master_key_id" {
  type        = string
  description = "KMS key id / alias / ARN used for SSE-KMS encryption. Null (default) uses SQS-managed SSE (SSE-SQS). Mutually exclusive with SSE-SQS: setting a key switches the queue to KMS."
  default     = null
}

# ---------------------------------------------------------------------------
# Delivery behaviour
# ---------------------------------------------------------------------------
variable "visibility_timeout_seconds" {
  type        = number
  description = "Time a message stays invisible to other consumers after being received (0–43200)."
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds must be between 0 and 43200 (12 hours)."
  }
}

variable "message_retention_seconds" {
  type        = number
  description = "How long a message is retained if not deleted (60–1209600). Default 345600 = 4 days."
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds must be between 60 (1 minute) and 1209600 (14 days)."
  }
}

variable "delay_seconds" {
  type        = number
  description = "Delivery delay applied to every message on the queue (0–900 seconds)."
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "delay_seconds must be between 0 and 900 (15 minutes)."
  }
}

# ---------------------------------------------------------------------------
# Dead-letter queue
# ---------------------------------------------------------------------------
variable "max_receive_count" {
  type        = number
  description = "Number of receives after which a message is moved to the dead-letter queue. 0 (default) disables the DLQ; any value > 0 creates a DLQ and wires the main queue's redrive policy to it."
  default     = 0

  validation {
    condition     = var.max_receive_count >= 0
    error_message = "max_receive_count must be 0 (no DLQ) or greater."
  }
}

# ---------------------------------------------------------------------------
# Access policy
# ---------------------------------------------------------------------------
variable "policy_principals" {
  type        = list(string)
  description = "IAM principal ARNs granted sqs:SendMessage / sqs:ReceiveMessage on the queue via a queue policy. When non-empty a policy is attached that also denies any request made without TLS (aws:SecureTransport=false). Empty (default) attaches no queue policy."
  default     = []
}
