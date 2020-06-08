data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
    type = "demo"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public-a"
    type = "demo"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "public-b"
    type = "demo"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private-a"
    type = "demo"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-b"
    type = "demo"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internet-gateway"
    type = "demo"
  }
}

resource "aws_eip" "nat_private-a" {
  vpc = true
  tags = {
    Name = "nat-a"
    type = "demo"
  }
}

resource "aws_eip" "nat_private-b" {
  vpc = true
  tags = {
    Name = "nat-b"
    type = "demo"
  }
}

resource "aws_nat_gateway" "gw-private-a" {
  subnet_id     = aws_subnet.public-a.id
  allocation_id = aws_eip.nat_private-a.id
  tags = {
    Name = "private-a"
    type = "demo"
  }
}

resource "aws_nat_gateway" "gw-private-b" {
  subnet_id     = aws_subnet.public-b.id
  allocation_id = aws_eip.nat_private-b.id
  tags = {
    Name = "private-b"
    type = "demo"
  }
}

resource "aws_route_table" "public-route-a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-a"
    type = "demo"
  }
}

resource "aws_route_table" "public-route-b" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-b"
    type = "demo"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public-route-a.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public-route-b.id
}

resource "aws_route_table" "private-route-a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-private-a.id
  }

  tags = {
    Name = "private-route-a"
    type = "demo"

  }
}

resource "aws_route_table" "private-route-b" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-private-b.id
  }

  tags = {
    Name = "private-route-b"
    type = "demo"
  }
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private-route-a.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private-route-b.id
}

resource "aws_security_group" "alb-sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
    type = "demo"
  }
}

resource "aws_security_group" "ecs" {
  name   = "ecs-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
    description = "Allow 9000 inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg"
    type = "demo"
  }
}

resource "aws_security_group" "db" {
  name   = "db-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description = "Allow 5432 inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
    type = "demo"
  }
}

resource "aws_security_group" "redis" {
  name   = "redis-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs.id]
    description = "Allow 6379 inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-sg"
    type = "demo"
  }
}