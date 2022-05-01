provider "aws" {
  region = "eu-west-1"
}


# VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block       					= var.vpc_cidr
  instance_tenancy 					= var.instance_tenancy
  enable_dns_hostnames             	= var.enable_dns_hostnames
  enable_dns_support              	= var.enable_dns_support
  tags = {
    Name = "TerraVPC"
  }
}

resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  count = length(var.subnets_cidr_public)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.subnets_cidr_public,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.subnets_cidr_private)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.subnets_cidr_private,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index+1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "Public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "Private_rt"
  }
}  

resource "aws_route_table_association" "a" {
  count = length(var.subnets_cidr_public)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}

}  

resource "aws_route_table_association" "b" {
  count = length(var.subnets_cidr_private)
  subnet_id      = element(aws_subnet.private.*.id,count.index)
  route_table_id = aws_route_table.private_rt.id
}
