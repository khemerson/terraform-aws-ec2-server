variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-3"
}

variable "ami_id" {
  description = "AMI ID available in the selected region"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR allowed to reach SSH (your public IP as /32)"
  type        = string
}
