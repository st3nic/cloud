#Create a single EC2 instance in the London region using Terraform

# configure the aws provider
provider "aws" {
  region = "eu-west-2"
}


resource "aws_instance" "myserver" {
  ami = "ami-0505148b3591e4c07"
  instance_type = "t2.micro"
  key_name = "steven-aws"

  tags = {
    Name = "MyFirstTerraformServer"
  }
}
