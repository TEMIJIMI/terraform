provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "Altschool-Assignment_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Altschool-Assignment_VPC"
  }
}

# create IGW
resource "aws_internet_gateway" "Altschool-Assignment_igw" {
  vpc_id = aws_vpc.Altschool-Assignment_vpc.id
  tags = {
    Name = "Altschool-Assignment_IGW"
  }
}

# create public route table
resource "aws_route_table" "Altschool-Assignment_public_route_table" {
  vpc_id = aws_vpc.Altschool-Assignment_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Altschool-Assignment_igw.id
  }

  tags = {
    Name = "Altschool-Assignment_public_route_table"
  }
}

# connect public route table to public subnet 1

resource "aws_route_table_association" "Altschool-Assignment_public_subnet_1" {
  subnet_id = aws_subnet.Altschool-Assignment_public_subnet_1.id
  route_table_id = aws_route_table.Altschool-Assignment_public_route_table.id
}

# connect public route table to public subnet 2

resource "aws_route_table_association" "Altschool-Assignment_public_subnet_2" {
  subnet_id = aws_subnet.Altschool-Assignment_public_subnet_2.id
  route_table_id = aws_route_table.Altschool-Assignment_public_route_table.id
}

# create public subnet 1

resource "aws_subnet" "Altschool-Assignment_public_subnet_1" {
  vpc_id = aws_vpc.Altschool-Assignment_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "Altschool-Assignment_public_subnet_1"
  }
}

# create public subnet 2

resource "aws_subnet" "Altschool-Assignment_public_subnet_2" {
  vpc_id = aws_vpc.Altschool-Assignment_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  tags = {
    Name = "Altschool-Assignment_public_subnet_2"
  }
}

resource "aws_network_acl" "Altschool-Assignment_public_network_acl" {
  vpc_id = aws_vpc.Altschool-Assignment_vpc.id
  subnet_ids = [aws_subnet.Altschool-Assignment_public_subnet_1.id, aws_subnet.Altschool-Assignment_public_subnet_2.id]
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
}

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# create security group for load balancer

resource "aws_security_group" "Altschool-Assignment_lb_security_group" {
  name = "Altschool-Assignment_lb_security_group"
  description = "Allow inbound traffic from the internet"
  vpc_id = aws_vpc.Altschool-Assignment_vpc.id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  
}

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  # create security group to allow port 22, 80, 443

  resource "aws_security_group" "Altschool-Assignment_security_group" {
    name = "Altschool-Assignment_security_group"
    description = "Allow inbound traffic from the internet"
    vpc_id = aws_vpc.Altschool-Assignment_vpc.id
  
    ingress {
      description = "HTTP"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = [aws_security_group.Altschool-Assignment_lb_security_group.id]  
  }

    ingress {
      description = "HTTPS"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = [aws_security_group.Altschool-Assignment_lb_security_group.id]
    }

    ingress {
      description = "SSH"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_groups = [aws_security_group.Altschool-Assignment_lb_security_group.id]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "Altschool-Assignment_security_group"
    }
  }

  # create instances

  resource "aws_instance" "Altschool-Assignment_instance1" {
    ami = "ami-00874d747dde814fa"
    instance_type = "t2.micro"
    key_name = "Altschool-key"
    subnet_id = aws_subnet.Altschool-Assignment_public_subnet_1.id
    vpc_security_group_ids = [aws_security_group.Altschool-Assignment_security_group.id]
    availability_zone = "us-east-1a"

    tags = {
      Name = "Altschool-Assignment_instance-1"
      source = "terraform"
    }
  }

  resource "aws_instance" "Altschool-Assignment_instance2" {
    ami = "ami-00874d747dde814fa"
    instance_type = "t2.micro"
    key_name = "Altschool-key"
    subnet_id = aws_subnet.Altschool-Assignment_public_subnet_2.id
    vpc_security_group_ids = [aws_security_group.Altschool-Assignment_security_group.id]
    availability_zone = "us-east-1b"

    tags = {
      Name = "Altschool-Assignment_instance-2"
      source = "terraform"
    }
  }

  resource "aws_instance" "Altschool-Assignment_instance3" {
    ami = "ami-00874d747dde814fa"
    instance_type = "t2.micro"
    key_name = "Altschool-key"
    subnet_id = aws_subnet.Altschool-Assignment_public_subnet_1.id
    vpc_security_group_ids = [aws_security_group.Altschool-Assignment_security_group.id]
    availability_zone = "us-east-1a"

    tags = {
      Name = "Altschool-Assignment_instance-3"
      source = "terraform"
    }
  }

  # create a file to store IP addresses of instances

  resource "local_file" "Ip_address" {
    filename = "/vagrant/terraform/host-inventory"
    content  = <<EOT
  ${aws_instance.Altschool-Assignment_instance1.public_ip}
  ${aws_instance.Altschool-Assignment_instance2.public_ip}
  ${aws_instance.Altschool-Assignment_instance3.public_ip}
   EOT
  }

  # create a load balancer

  resource "aws_lb" "Altschool-Assignment_lb" {
    name               = "Altschool-Assignment-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.Altschool-Assignment_lb_security_group.id]
    subnets            = [aws_subnet.Altschool-Assignment_public_subnet_1.id, aws_subnet.Altschool-Assignment_public_subnet_2.id]
  # enable_cross_zone_load_balancing = true
    enable_deletion_protection = false
    depends_on = [aws_instance.Altschool-Assignment_instance1, aws_instance.Altschool-Assignment_instance2, aws_instance.Altschool-Assignment_instance3]
  }

  # create a target group

  resource "aws_lb_target_group" "Altschool-Assignment_target_group" {
    name     = "Altschool-Asignment-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.Altschool-Assignment_vpc.id
    target_type = "instance"
  
     health_check {
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 3
        interval            = 30
        path                = "/"
        matcher             = "200-399"
        protocol            = "HTTP"
      }
  }

  # create a listener

  resource "aws_lb_listener" "Altschool-Assignment_listener" {
    load_balancer_arn = aws_lb.Altschool-Assignment_lb.arn
    port              = "80"
    protocol          = "HTTP"
    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.Altschool-Assignment_target_group.arn
    }
  }

  # create a listener rule

  resource "aws_lb_listener_rule" "Altschool-Assignment_listener_rule" {
    listener_arn = aws_lb_listener.Altschool-Assignment_listener.arn
    priority     = 1
    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.Altschool-Assignment_target_group.arn
    }
    condition {
      path_pattern {
        values = ["/"]
      }
    }
  }

  # Attach the target group to the lb

  resource "aws_lb_target_group_attachment" "Altschool-Assignment_target_group_attachment1" {
    target_group_arn = aws_lb_target_group.Altschool-Assignment_target_group.arn
    target_id        = aws_instance.Altschool-Assignment_instance1.id
    port             = 80
  }

  resource "aws_lb_target_group_attachment" "Altschool-Assignment_target_group_attachment2" {
    target_group_arn = aws_lb_target_group.Altschool-Assignment_target_group.arn
    target_id        = aws_instance.Altschool-Assignment_instance2.id
    port             = 80
  }

  resource "aws_lb_target_group_attachment" "Altschool-Assignment_target_group_attachment3" {
    target_group_arn = aws_lb_target_group.Altschool-Assignment_target_group.arn
    target_id        = aws_instance.Altschool-Assignment_instance3.id
    port             = 80
  }
