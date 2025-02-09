provider "aws" {
  region     = "us-west-2"
 access_key = "default"
  secret_key = "default"
}
resource "aws_instance" "cloudec2" {
  ami         = "ami-0005ee01bca55ab66"
  instance_type = "t3.micro"
    tags = {
    Name = "Terrformtest"
  }
}
