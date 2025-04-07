resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table_association" "rtA1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_route_table_association" "rtA2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.myRT.id
}


####sg

resource "aws_security_group" "d-sg" {
  name   = "web_SG"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "This is our web"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "This is ssh port "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Web-sG "
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "demo-test-bucket-12354"
}



resource "aws_instance" "webserver-1" {
  ami                    = "ami-002f6e91abff6eb96"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.d-sg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver-2" {
  ami                    = "ami-002f6e91abff6eb96"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.d-sg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))
}

##----create load balancer -------##
resource "aws_lb" "myALB" {
  name               = "demoALB"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.d-sg.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "application-demo"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "target-1"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach-1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver-1.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "attach-2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver-2.id
  port             = 80
}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myALB.dns_name
}
