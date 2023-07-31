# OPEN VPC
resource "aws_vpc" "Web_Vpc" {
  cidr_block           = "172.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = var.vpc_information.name
  }
}

# Launch 2 private and public subnets in 2 availabiliy zones
resource "aws_subnet" "Web-pub-subnet1" {
  availability_zone       = "us-east-1a"
  cidr_block              = "172.168.0.0/30"
  vpc_id                  = aws_vpc.Web_Vpc.id
  map_public_ip_on_launch = true

  tags = {
    "Name" = var.vpc_information.public1
  }
}

resource "aws_subnet" "Web-pub-subnet2" {
  availability_zone       = "us-east-1b"
  cidr_block              = "172.168.0.0/30"
  vpc_id                  = aws_vpc.Web_Vpc.id
  map_public_ip_on_launch = true

  tags = {
    "Name" = var.vpc_information.public2
  }
}

resource "aws_subnet" "Web-priv-subnet1" {
  availability_zone       = "us-east-1a"
  cidr_block              = "172.168.1.0/30" #
  vpc_id                  = aws_vpc.Web_Vpc.id
  map_public_ip_on_launch = false

  tags = {
    "Name" = var.vpc_information.private1
  }
}

resource "aws_subnet" "Web-priv-subnet2" {
  availability_zone       = "us-east-1b"
  cidr_block              = "172.168.1.0/30"
  vpc_id                  = aws_vpc.Web_Vpc.id
  map_public_ip_on_launch = false

  tags = {
    "Name" = var.vpc_information.private2
  }
}

#Create internet gateway and attach to the VPC
resource "aws_internet_gateway" "Web_igw" {
  vpc_id = aws_vpc.Web_Vpc.id

  tags = {
    "Name" = "tera-igw"
  }
}

# Create route table
resource "aws_route_table" "Web_rt" {
  vpc_id = aws_vpc.Web_Vpc.id

  tags = {
    "Name" = "tera-routeTable-ig"
  }
}

# Create route
resource "aws_route" "Web_default_r" {
  route_table_id         = aws_route_table.Web_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Web_igw.id

}

#Associate route table
resource "aws_route_table_association" "Web_pubSubnet_r1" {
  subnet_id      = aws_subnet.Web-pub-subnet1.id
  route_table_id = aws_route_table.Web_rt.id

}
#Associate route table
resource "aws_route_table_association" "Web_pubSubnet_r2" {
  subnet_id      = aws_subnet.Web-pub-subnet2.id
  route_table_id = aws_route_table.Web_rt.id

}
# Allocate elastic IP
resource "aws_eip" "Web_nat_eip" {
  vpc = true
  tags = {
    "Name" = "CustomEIP"
  }
}

# Create NAT gateway  
resource "aws_nat_gateway" "Web_ngw" {
  subnet_id     = aws_subnet.Web-pub-subnet1.id #nat gateway should be in public subnet
  allocation_id = aws_eip.Web_nat_eip.id

  tags = {
    "Name" = "tera-natgw-az1a"
  }
}

# Create route table
resource "aws_route_table" "Web_ngw_rt" {
  vpc_id = aws_vpc.Web_Vpc.id

  tags = {
    "Name" = "tera-routetable-nat"
  }
}

# Create route
resource "aws_route" "Web_ngw_r" {
  route_table_id         = aws_route_table.Web_ngw_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.Web_ngw.id
}

# Associate route table
resource "aws_route_table_association" "Web_priv_r1" {
  subnet_id      = aws_subnet.Web-priv-subnet1.id
  route_table_id = aws_route_table.Web_ngw_rt.id
}
# Associate route table
resource "aws_route_table_association" "Web_priv_r2" {
  subnet_id      = aws_subnet.Web-priv-subnet2.id
  route_table_id = aws_route_table.Web_ngw_rt.id
}
