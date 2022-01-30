resource "aws_iam_instance_profile" "ec2-profile-devops" {
  name = "ec2-profile-devops"
  role = "ec2-admin-role"
}