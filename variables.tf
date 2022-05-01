variable "aws_region" {
	default = "eu-west-1"
}

variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr_public" {
	type = list
	default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "subnets_cidr_private" {
	type = list
	default = ["10.20.3.0/24", "10.20.4.0/24"]
}

variable "azs" {
	type = list
	default = ["eu-west-1a", "eu-west-1b"]
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "rules_inbound_private_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.159.94.240/29","10.189.0.0/23"]
    },
    {
      port = 0
      proto = "-1"
      security_groups = [aws_security_group.private_sg.id]
    }
    ]
}

variable "rules_outbound_private_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.159.94.240/29","10.189.0.0/23"]
    },
    {
      port = 0
      proto = "-1"
      security_groups = [aws_security_group.public_sg.id]
    }
    ]
}
