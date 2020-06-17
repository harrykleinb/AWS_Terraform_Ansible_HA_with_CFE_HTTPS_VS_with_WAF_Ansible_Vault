provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

#Creation of the VPC 

resource "aws_vpc" "vpc_lab" {
  cidr_block           = var.vpc_lab_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "${var.user_id}_vpc_lab"
  }
}


#Creation of the management subnet in 2 AZ

resource "aws_subnet" "management" {
  vpc_id                  = aws_vpc.vpc_lab.id
  cidr_block              = var.mgmt_subnet
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.user_id}_mgmt_subnet"
  }
}


resource "aws_subnet" "management_b" {
  vpc_id                  = aws_vpc.vpc_lab.id
  cidr_block              = var.mgmt_subnet_b
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.aws_region}b"

  tags = {
    Name = "${var.user_id}_mgmt_subnet_b"
  }
}


#Creation of the internal subnet for BIG-IP

resource "aws_subnet" "internal_bigip" {
  vpc_id                  = aws_vpc.vpc_lab.id
  cidr_block              = var.internal_subnet_bigip
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.user_id}_internal_subnet_bigip"
  }
}


#Creation of the external subnet for BIG-IP.

resource "aws_subnet" "external_bigip" {
  vpc_id                  = aws_vpc.vpc_lab.id
  cidr_block              = var.external_subnet_bigip
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "${var.user_id}_external_subnet_bigip"
  }
}


#Creation of the Internet Gateway in the vpc

resource "aws_internet_gateway" "internet_gw_lab" {
  vpc_id = aws_vpc.vpc_lab.id

  tags = {
    Name = "${var.user_id}_internet-gateway_lab"
  }
}


#Creation of a Route Table in the VPC

resource "aws_route_table" "rt1_lab" {
  vpc_id = aws_vpc.vpc_lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw_lab.id
  }

  tags = {
    Name = "${var.user_id}_Route_Table1_lab"
  }
}


#Association Route Table 1 with the VPC
resource "aws_main_route_table_association" "association_route_vpc" {
  vpc_id         = aws_vpc.vpc_lab.id
  route_table_id = aws_route_table.rt1_lab.id
}


