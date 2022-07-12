module "kms_ebs" {
  source                  = "../../common/modules/tf-aws-kms-key"
  description             = "Key for encrypting EBS"
  deletion_window_in_days = "30"
  enable_key_rotation     = "true"
  alias                   = "alias/ebs"

  iam_policy = templatefile("../../common/templates/policies/kms_policy_ebs.tpl", {
    id_prefix  = "CNB"
    account_id = data.aws_caller_identity.current.account_id
  })

  tags = {
    "Name" = "${local.naming_prefix}-CNB-EBS-KMS"
  }
}
