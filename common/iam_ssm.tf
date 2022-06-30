resource "aws_iam_role" "cnb_ec2_ssm" {
  name = var.iam.iam_role_name
  # path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "cnb_ec2_ssm" {
  name = var.iam.instance_profile_name
  role = aws_iam_role.cnb_ec2_ssm.name
}


data "aws_iam_policy" "ssm_managed_instance_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_policy" {
  role       = aws_iam_role.cnb_ec2_ssm.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_policy.arn
}

data "aws_iam_policy" "secrets_manager_policy" {
  name = "SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy" {
  role       = aws_iam_role.cnb_ec2_ssm.name
  policy_arn = data.aws_iam_policy.secrets_manager_policy.arn
}

data "aws_iam_policy" "cloudwatch_agent_admin_policy" {
  name = "CloudWatchAgentAdminPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_admin_policy" {
  role       = aws_iam_role.cnb_ec2_ssm.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_admin_policy.arn
}

data "aws_iam_policy" "cloudwatch_agent_server_policy" {
  name = "CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.cnb_ec2_ssm.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_server_policy.arn
}


# resource "aws_iam_role_policy" "cnb_ec2_ssm" {
#   name = var.iam.iam_role_policy_name
#   role = aws_iam_role.cnb_ec2_ssm.id

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ssm:DescribeAssociation",
#                 "ssm:GetDeployablePatchSnapshotForInstance",
#                 "ssm:GetDocument",
#                 "ssm:DescribeDocument",
#                 "ssm:GetManifest",
#                 "ssm:GetParameter",
#                 "ssm:GetParameters",
#                 "ssm:ListAssociations",
#                 "ssm:ListInstanceAssociations",
#                 "ssm:PutInventory",
#                 "ssm:PutComplianceItems",
#                 "ssm:PutConfigurePackageResult",
#                 "ssm:UpdateAssociationStatus",
#                 "ssm:UpdateInstanceAssociationStatus",
#                 "ssm:UpdateInstanceInformation",
#                 "secretsmanager:GetResourcePolicy",
#                 "secretsmanager:GetSecretValue",
#                 "secretsmanager:DescribeSecret",
#                 "secretsmanager:ListSecretVersionIds",
#                 "secretsmanager:ListSecrets"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ssmmessages:CreateControlChannel",
#                 "ssmmessages:CreateDataChannel",
#                 "ssmmessages:OpenControlChannel",
#                 "ssmmessages:OpenDataChannel"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2messages:AcknowledgeMessage",
#                 "ec2messages:DeleteMessage",
#                 "ec2messages:FailMessage",
#                 "ec2messages:GetEndpoint",
#                 "ec2messages:GetMessages",
#                 "ec2messages:SendReply"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }


