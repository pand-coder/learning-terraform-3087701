# --------------------------------------------------------------------
# IAM role that EC2 instances can assume to receive temporary,
# auto-rotated AWS credentials instead of hardcoded keys.
# --------------------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "blog-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# --------------------------------------------------------------------
# AWS-managed policy granting the permissions Session Manager needs
# to connect to the instance without SSH or open inbound ports.
# --------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --------------------------------------------------------------------
# Required wrapper linking a role to an EC2 instance — AWS does not
# allow attaching an IAM role to an instance directly.
# --------------------------------------------------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "blog-ec2-profile"
  role = aws_iam_role.ec2_role.name
}