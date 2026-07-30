# Retrieve the latest Amazon Linux 2023 x86_64 AMI.
data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# IAM role assumed by the Jenkins EC2 instance.
resource "aws_iam_role" "jenkins_ec2_role" {
  name = "techchallenge2-jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "TechChallenge2"
  }
}

# Allows access through AWS Systems Manager Session Manager.
resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "jenkins_eks" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy" "jenkins_describe_cluster" {
  name = "jenkins-describe-cluster"
  role = aws_iam_role.jenkins_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster"
        ]

        Resource = "*"
      }
    ]
  })
}

# Makes the IAM role attachable to an EC2 instance.
resource "aws_iam_instance_profile" "jenkins" {
  name = "techchallenge2-jenkins-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}

# Security group for the Jenkins web interface.
resource "aws_security_group" "jenkins" {
  name        = "techchallenge2-jenkins-sg"
  description = "Allow Jenkins access from the administrator public IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Jenkins web interface"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "techchallenge2-jenkins-sg"
    Project = "TechChallenge2"
  }
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type               = var.jenkins_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  user_data                   = file("${path.module}/scripts/install-jenkins.sh")
  user_data_replace_on_change = true

  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name    = "techchallenge2-jenkins"
    Project = "TechChallenge2"
  }
}