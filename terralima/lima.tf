variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "us-east-1"
}


provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

variable "limakey_name" {
  default = "limakey"
}

resource "tls_private_key" "limaprivate" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.limakey_name}"
  public_key = "${tls_private_key.limaprivate.public_key_openssh}"
}

resource "aws_eip" "prismadb-ip" {
  instance = "${aws_instance.prisma-db.id}"
  provisioner "local-exec" {
    command = "echo ${aws_eip.prismadb-ip.public_ip} > ip_addresss.txt"
  }
}



resource "aws_instance" "prisma-db" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  provisioner "local-exec" {
    command = "echo ${aws_instance.prisma-db.public_ip} > ip_address.txt"
  }

  tags {
    Name = "Prisma DB"
  }
}

output "limakey" {
  value = "${aws_key_pair.generated_key.public_key}"
}
