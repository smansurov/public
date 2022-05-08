# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
    "Name" = var.vpc_name
  }
}

# Create Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

 # Create Route Table -  Public
 resource "aws_route_table" "rtpublic" {
   vpc_id = aws_vpc.myvpc.id

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
   }

   tags = {
    Name = "rt-(${var.vpc_name})-public"
   }
}

 # Create Route Table -  Private
 resource "aws_route_table" "rtprivate" {
   vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "rt-(${var.vpc_name})-private"
  }
}

# Create a VPC subnet
resource "aws_subnet" "subnet" {
  #count = length(data.aws_availability_zones.available.names)
  count = length(var.vpc_subnet)
  
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "${element(var.vpc_subnet, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "subnet-${count.index+1}-${element(var.vpc_subnet_type, count.index)}"
    SubnetType = "${element(var.vpc_subnet_type, count.index)}"
  }

}
 
# Identify PUBLIC subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.myvpc.id]
  }

  tags = {
    SubnetType = "public"
  }
}

# Create Route Table association for PUBLIC subnets
resource "aws_route_table_association" "a" {
  for_each = toset(data.aws_subnets.public.ids)
  subnet_id = each.value
  route_table_id = aws_route_table.rtpublic.id
}

# Identify PRIVATE subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.myvpc.id]
  }

  tags = {
    SubnetType = "private"
  }
}

# Create Route Table association for PRIVATE subnets
resource "aws_route_table_association" "b" {
  for_each = toset(data.aws_subnets.private.ids)
  subnet_id = each.value
  route_table_id = aws_route_table.rtprivate.id
}

# Create NAT gw per PRIVATE Subnet
#resource "aws_nat_gateway" "natgw" {
#  for_each = toset(data.aws_subnets.private.ids)
##  allocation_id = aws_eip.example.id
#  subnet_id = each.value
#}


# Create Security Group allowing ports 80 and 443 in
resource "aws_security_group" "web" {
  name        = "allow_80_443"
  description = "Allow inbound traffic on port 80 and 443"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "Port 443 in"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Port 80 in"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_80_443"
  }
}

