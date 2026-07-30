variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "jenkins_allowed_cidr" {
  description = "Public IPv4 CIDR allowed to access Jenkins"
  type        = string
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "helm_version" {
  description = "Version of Helm installed on the Jenkins server"
  type        = string
  default     = "v3.18.4"
}