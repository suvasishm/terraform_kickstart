provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "tf_kickstart_ec2" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.tf_kickstart_ec2.public_ip} > ip_address.txt"
  }

  key_name = aws_key_pair.tf_kickstart_key_pair.key_name

 connection {
    type     = "ssh"
    user     = "root"
    private_key = file("~/.ssh/id_rsa")
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
}

resource "aws_eip" "ip" {
    vpc = true
    instance = aws_instance.tf_kickstart_ec2.id
}

resource "aws_key_pair" "tf_kickstart_key_pair" {
  key_name = "kickstartkey"
  public_key = file("~/.ssh/id_rsa.pub")
}

