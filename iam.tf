resource "aws_iam_role" "practice_ha_role" {
  name               = "practice-ha-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "practice_ha_s3_policy" {
  name   = "practice-ha-s3-policy"
  role   = aws_iam_role.practice_ha_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "practice_ha_profile" {
  name = "practice-ha-profile"
  role = aws_iam_role.practice_ha_role.id
}