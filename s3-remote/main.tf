provider "aws" {
    region = "ap-south-1"
}
resource "aws_instance" "devendra" {
  instance_type = "t2.micro"
  ami = "ami-0e35ddab05955cf57"
  key_name = "demo"
  tags = {
    Name = "web-test-61"
  }
}

# resource "aws_s3_bucket" "s3_bucket" {
#     bucket = "demo-s3-112345"
# }
# isko alg script me run karke karna h 
# terraform init 
# terraform apply 
# jb he backend.tf run karna h 