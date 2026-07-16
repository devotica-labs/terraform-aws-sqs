# Queue access policy document — a Send/Receive grant to policy_principals plus
# a blanket Deny for any request that isn't made over TLS. Only rendered when
# principals are supplied (local.need_policy).
data "aws_iam_policy_document" "queue" {
  count = local.need_policy ? 1 : 0

  statement {
    sid    = "AllowPrincipals"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.policy_principals
    }
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
    ]
    resources = [aws_sqs_queue.this[0].arn]
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.this[0].arn]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
