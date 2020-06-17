
resource "aws_s3_bucket" "cfe" {
  bucket = "${var.user_id}-cfe-terraform"

  force_destroy = true

  tags = {
    owner			= "${var.user_id}"
    f5_cloud_failover_label	= "${var.cfe_label}"
  }
}



resource "aws_iam_role_policy" "policy_cfe" {
  name        = "${var.user_id}_inline_policy_f5_cfe"
  role	      = aws_iam_role.role_cfe.id
#  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeAddresses",
                "ec2:AssociateAddress",
                "ec2:DisassociateAddress",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeNetworkInterfaceAttribute",
                "ec2:DescribeRouteTables",
                "ec2:ReplaceRoute",
                "ec2:assignprivateipaddresses",
                "sts:AssumeRole",
                "s3:ListAllMyBuckets",
                "ec2:UnassignPrivateIpAddresses"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketTagging"
            ],
            "Resource": "arn:*:s3:::${var.user_id}-cfe-terraform",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:*:s3:::${var.user_id}-cfe-terraform/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:CreateRoute",
                "ec2:ReplaceRoute"
            ],
            "Resource": "arn:*:ec2:${var.aws_region}:{var.account_id_aws}:route-table/*",
            "Effect": "Allow"
        }
    ]
}
EOF

}


resource "aws_iam_role" "role_cfe" {
  name = "${var.user_id}_role_cfe"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  depends_on = [aws_s3_bucket.cfe]
}


/*
resource "aws_iam_role_policy_attachment" "attach_to_cfe_role" {
    role = aws_iam_role.role_cfe.name
    policy_arn = aws_iam_policy.policy_cfe.arn
   
    depends_on = [aws_iam_role.role_cfe]
}
*/



resource "aws_iam_instance_profile" "profile_cfe" {
  name = "${var.user_id}_profile_cfe"
  role = "${var.user_id}_role_cfe"
#  depends_on = [aws_iam_role_policy_attachment.attach_to_cfe_role,aws_iam_role.role_cfe]
  depends_on = [aws_iam_role.role_cfe]
}


