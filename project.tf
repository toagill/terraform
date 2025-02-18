provider "aws" {
  region     = "us-west-2"
 access_key = "defaultkey"
  secret_key = "defaultkey"
}
resource "aws_vpc" "cloudvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "cloudvpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.cloudvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.cloudvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_security_group" "cloudsg" {
  name        = "cloudsg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cloudvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudsg"
  }
}

resource "aws_internet_gateway" "cloud-igw" {
  vpc_id = aws_vpc.cloudvpc.id

  tags = {
    Name = "cloud-igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cloudvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloud-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.cloudvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.cloud-nat.id
  }

  tags = {
    Name = "private-rt"
  }
depends_on =[aws_nat_gateway.cloud-nat]
}
resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_key_pair" "cloudkey" {
  key_name   = "cloudindiakey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC30GrVWmxr6efO5DIge8LbsRZoZRydUd4SoQ6wwFR9T/bmEkch5UcuA+zFFG9Hf6z5kccn5WG61K8qYYgNSqRfXIhb5P2q9/KmI9TPsCWlr9/mtcCq1wFNhDPMhkccmFttyxKv0KC56cNTN9YGVXVY4kBn/XKh12znDyQDGT1oEimAnHPnQgcKtPN21G7cZnNldClmX/hiI/aiXGSSG1ygVo7MVErO7tcfP8dlHUrBBRI5eu1KS3KlTRyqjy6CUf9eaYsEhJElzN+1JJUkbslrtJDFUjGmV+enRV3uUynKAINXNfmvPrl4let2SejSwEtWlF+UFpJFGy/DtulaTNd7 root@ip-172-31-29-234.eu-west-2.compute.internal"
}

resource "aws_instance" "Web-instance" {
  ami           = "ami-09245d5773578a1d6"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.cloudsg.id]
  key_name      = "cloudindiakey"

  tags = {
    Name = "Web-Instance"
  }
}

resource "aws_instance" "DB-instance" {
  ami           = "ami-09245d5773578a1d6"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.cloudsg.id]
  key_name      = "cloudindiakey"

  tags = {
    Name = "DB-Instance"
  }
}

resource "aws_eip" "cloudeip" {
  instance = aws_instance.Web-instance.id
  domain   = "vpc"
}

resource "aws_eip" "cloud-natip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "cloud-nat" {
  allocation_id = aws_eip.cloud-natip.id
  subnet_id     = aws_subnet.public-subnet.id
 depends_on    = [aws_eip.cloud-natip, aws_internet_gateway.cloud-igw]
}
