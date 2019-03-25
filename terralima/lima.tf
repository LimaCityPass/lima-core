variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "us-east-1"
}
variable "lima_base_script" {
  default = "https://raw.githubusercontent.com/limacitypass/util/master/lima-base.sh"
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

  provisioner "local-exec" {
    command = "echo '${tls_private_key.limaprivate.private_key_pem}' > limakey.pem" 
  }

   provisioner "local-exec" {
    command = "chmod 400 limakey.pem" 
  }
}

resource "aws_eip" "prismadb-ip" {
  instance = "${aws_instance.prisma-db.id}"
  provisioner "local-exec" {
    command = "echo 'ssh -i \"limakey.pem\" ubuntu@${aws_eip.prismadb-ip.public_ip}' > limadb.txt"
  }
}

resource "aws_instance" "prisma-db" {
  ami           = "ami-0a313d6098716f372"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("limakey.pem")}"
    }

    inline= [
      "curl -fsSL ${var.lima_base_script} -o lima-base.sh",
      "sudo sh lima-base.sh",
      "mkdir ~/prisma"
    ]
  }
  
  provisioner "file" {
    source      = "prisma/docker-compose.yml"
    destination = "/home/ubuntu/prisma/prisma.yml"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      # private_key = "${aws_key_pair.generated_key.public_key}"
      private_key = "${file("limakey.pem")}"
    }
  }
  
  tags {
    Name = "Prisma DB"
  }
}
