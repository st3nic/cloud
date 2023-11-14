# 1 Create VPC
# 2 Create Internet Gateway
# 3 Create Route Table
# 4 Create Subnet
# 5 Associate Subnet with Route Table
# 6 Create Security Group, allow ports 22 and 80
# 7 Create ec2 instance
# 8 install docker
# 9 run nginx image 


#1 create vpc
resource "aws_vpc" "web-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "web-vpc"
  }
}

#2 create internet gateway
resource "aws_internet_gateway" "web-gw" {
  vpc_id = aws_vpc.web-vpc.id

  tags = {
    Name = "web-gw"
  }
}

#create route table
resource "aws_route_table" "web-route" {
  vpc_id = aws_vpc.web-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-gw.id
  }

  tags = {
    Name = "web-route"
  }
}


#create subnet
resource "aws_subnet" "web-subnet" {
  vpc_id     = aws_vpc.web-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "web-subnet"
  }
}


#create route table association
resource "aws_route_table_association" "route-table-association" {
  subnet_id = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-route.id
}


#create security group
resource "aws_security_group" "allow-web" {
  name        = "allow-web"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.web-vpc.id

  ingress {
    description      = "Http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Would normally be locked down to certain IP addresses
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-web"
  }
}


#create ec2 instance
resource "aws_instance" "webserver" {
  ami = "ami-0505148b3591e4c07"
  instance_type = "t2.micro"
  availability_zone = "eu-west-2a"
  key_name = "steven-aws"
  subnet_id = aws_subnet.web-subnet.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow-web.id]
  private_ip = "10.0.1.100"
 
  user_data = <<-EOF
            #!/bin/bash
            sudo apt update
            sudo apt install docker.io -y
            sudo systemctl start docker
            sudo docker run --name nginx -d -p 80:80 nginx
            EOF

    tags = {
        Name = "web server"
  }
}
