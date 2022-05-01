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
    Name = "Subnet-Public${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.subnets_cidr_private)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.subnets_cidr_private,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-Private${count.index+1}"
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
    gateway_id = aws_nat_gateway.example.id
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

  
resource "aws_route_table_association" "b" {
  count = length(var.subnets_cidr_private)
  subnet_id      = element(aws_subnet.private.*.id,count.index)
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "nat" {
  vpc              = true
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["Subnet-Public1"]
  }
  depends_on = [aws_subnet.public]
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = data.aws_subnet.selected.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.terra_igw]
}

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.terra_vpc.id

  tags = {
    Name = "Test_VGW"
  }
}

resource "aws_customer_gateway" "oakbrook" {
  bgp_asn    = 65000
  ip_address = "207.223.34.132"
  type       = "ipsec.1"

  tags = {
    Name = "Test_Oakbrook_CGW"
  }
}

resource "aws_customer_gateway" "miami" {
  bgp_asn    = 65000
  ip_address = "66.165.187.241"
  type       = "ipsec.1"

  tags = {
    Name = "Test_Miami_CGW"
  }
}

resource "aws_vpn_connection" "Oakbrook" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.oakbrook.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = "Oakbrook_ipsec"
  }
  
}

resource "aws_vpn_connection" "Miami" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.miami.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = "Miami_ipsec"
  }
}

