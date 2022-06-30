resource "aws_kms_key" "default" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  policy                  = var.iam_policy
  tags                    = var.tags
}

resource "aws_kms_alias" "default" {
  name          = var.alias
  target_key_id = aws_kms_key.default.id
}
