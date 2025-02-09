provider "aws" {
  region     = "us-west-2"
 access_key = "defaultkey"
  secret_key = "defaultkey"
}
resource "aws_instance" "cloudec2" {
  ami         = "ami-0005ee01bca55ab66"
  instance_type = "t3.micro"
  count = 10
  tags = {
    Name = "Terrformtest"
  }
}
