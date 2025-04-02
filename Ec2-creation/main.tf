provider "aws" {
    region = "ap-south-1"
}
resource "aws_instance" "example" {
    ami = "ami-0e35ddab05955cf57"
    instance_type = "t2.micro"
    tags = {
      Name = "demo"
    }
    key_name = "demo"

    security_groups = [ aws_security_group.allow_ssh.name]
}
resource "aws_security_group" "allow_ssh" {
    name = "allow-ssh"
    description = "This is for allow ssh port 22"
    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress{
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    
}