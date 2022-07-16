# terraform {
#   backend "s3" {
#     bucket         = "cnb-tfstate-dev-test-netrix-edrans"
#     key            = "tfstate/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "CNB-terraform-locks"
#     encrypt        = true
#   }
# }

# resource "aws_dynamodb_table" "CNB-terraform_lock" {
#   name         = "CNB-terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# resource "aws_kms_key" "CNB-key" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }
# resource "aws_kms_alias" "CNB-key-alias" {
#   name          = "alias/CNB-test"
#   target_key_id = aws_kms_key.CNB-key.key_id
# }

# resource "aws_s3_bucket" "CNB-tfstate-dev-test" {
#   bucket = "cnb-tfstate-dev-test-netrix-edrans"
# }

# resource "aws_s3_bucket_versioning" "CNB-tfstate-dev-test-versioning" {
#   bucket = aws_s3_bucket.CNB-tfstate-dev-test.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "CNB-tfstate-dev-test-encryption" {
#   bucket = aws_s3_bucket.CNB-tfstate-dev-test.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.CNB-key.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }


