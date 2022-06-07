resource "aws_iam_user" "simple_user" {
  name = "simple_user"
}

resource "aws_iam_access_key" "simple_user_access_key" {
  user = aws_iam_user.simple_user.name
}

resource "aws_iam_user_policy" "simple_user_policy" {
  name = "simple_user_policy"
  user = aws_iam_user.simple_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetConnectionStatus",
                "ec2:DescribeInstances",
                "ssm:DescribeInstanceInformation",
                "ssm:DescribeSessions",
                "ssm:DescribeInstanceProperties"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetDocument",
                "ssm:UpdateDocument",
                "ssm:CreateDocument"                
            ],
            "Resource": [                
                "arn:aws:ssm:*:*:document/SSM-SessionManagerRunShell",
                "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:ResumeSession",
                "ssm:TerminateSession"
            ],
            "Resource": [                
                "arn:aws:ssm:*:*:session/simple_user-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:SendCommand",
                "ssm:StartSession"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"         
            ],
            "Condition": {
                "StringLike": {
                    "ssm:resourceTag/platform": [
                        "windows"
                    ]
                }
            }
        }        
    ]
}
EOF
}



