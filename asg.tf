#provider
provider "aws" {
        access_key = var.AWS_ACCESS_KEY
        secret_key = var.AWS_SECRET_KEY
        region     = var.AWS_REGION
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"

}


# Subnets
resource "aws_subnet" "main-public-1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"

    
}

resource "aws_subnet" "main-public-2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
}


# Internet GW
resource "aws_internet_gateway" "main-gw" {
    vpc_id = aws_vpc.main.id

}

# route tables public
resource "aws_route_table" "main-public-1" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-gw.id
    }

}

resource "aws_route_table" "main-public-2" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-gw.id
    }

}

#route associations public
resource "aws_route_table_association" "main-public-1" {
    subnet_id = aws_subnet.main-public-1.id
    route_table_id = aws_route_table.main-public-1.id
}

resource "aws_route_table_association" "main-public-2" {
    subnet_id = aws_subnet.main-public-2.id
    route_table_id = aws_route_table.main-public-2.id
}

#Security Groups
resource "aws_security_group" "allow-ssh" {
  vpc_id = aws_vpc.main.id
  name = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_launch_configuration" "test" {
  name_prefix = "test-"

  image_id = "ami-0947d2ba12ee1ff75" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"

  security_groups = [ aws_security_group.allow-ssh.id ]
  associate_public_ip_address = true


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test" {
  name = "aws_launch_configuration.test.name-asg"

  min_size             = var.min_size
  desired_capacity     = 2
  max_size             = var.max_size
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.test.name
  vpc_zone_identifier  = [
    aws_subnet.main-public-1.id, aws_subnet.main-public-2.id
  ]
 # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

}