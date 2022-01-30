provider "aws" {
  region  = "us-west-1"
}

resource "aws_instance" "ec2-uw1-1a-d-devops" {
  ami = "ami-01f87c43e618bf8f0"
  instance_type = "t2.micro"
  key_name = "devops"
  user_data = "${file("ec2_user_data.sh")}"
  iam_instance_profile = aws_iam_instance_profile.ec2-profile-devops.name

  tags = {
    Name = "ec2-uw1-1a-d-devops"
    Project = "devops"
  }

  security_groups = ["${aws_security_group.devops-sg.name}"]
}

output "public_ip" {
  value = "${aws_instance.ec2-uw1-1a-d-devops.public_ip}"
}
