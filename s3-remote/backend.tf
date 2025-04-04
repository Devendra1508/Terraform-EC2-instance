terraform {
  backend "s3" {
    bucket = "demo-s3-112345"
    region = "ap-south-1"
    key = "demo/terraform.tfstate"
  }
}
