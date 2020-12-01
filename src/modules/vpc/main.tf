
resource "aws_vpc" "_" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "${var.app-name}-vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc._.id
  tags = {
    Name = "${var.app-name}-gateway"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc._.id

  dynamic "route" {
    for_each = var.routes

    content {
      cidr_block     = route.value.cidr_block
      gateway_id     = aws_internet_gateway.gateway.id
      instance_id    = route.value.instance_id
      nat_gateway_id = route.value.nat_gateway_id
    }
  }
  tags = {
    Name = "${var.app-name}-route-table"
  }
}
resource "aws_subnet" "subnet-a" {
  vpc_id                  = aws_vpc._.id
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app-name}-subnet-a"
  }
}

resource "aws_subnet" "subnet-b" {
  vpc_id                  = aws_vpc._.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app-name}-subnet-b"
  }
}

resource "aws_subnet" "subnet-c" {
  vpc_id                  = aws_vpc._.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app-name}-subnet-c"
  }
}


output "_" {
  value = {
    vpc_id = aws_vpc._.id
    subnet_a = aws_subnet.subnet-a.id
    subnet_b = aws_subnet.subnet-b.id
    subnet_c = aws_subnet.subnet-c.id
  }
}