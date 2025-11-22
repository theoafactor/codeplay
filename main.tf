terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

## create firewall for ssh
resource "aws_security_group" "ssh" {
    name = "security_group_for-ssh"
    description = "this is basic group ssh"

    ingress {
        description = "basic ssh ingress rule"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "basic ssh egress rule"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

}

resource "aws_key_pair" "serverkey" {
    key_name = "server"
    public_key = file("/home/astronaut/teachings/codeplay/server1.pub")
}


resource "aws_instance" "server1" {
  ami           = "ami-0fa3fe0fa7920f68e"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name = aws_key_pair.serverkey.key_name


  ## add provisioner 
#   provisioner "file" {
#     source = "/home/astronaut/teachings/codeplay/install_docker.sh"
#     destination = "/tmp/install_docker.sh"
#     when = create

#     connection {
#       private_key = file("./server1")
#       type = "ssh"
#       user = "ec2-user"
#       host = self.public_ip 
#     }
#   }


  provisioner "remote-exec" {
    script = "/home/astronaut/teachings/codeplay/install_docker.sh"

    connection {
      private_key = file("./server1")
      type = "ssh"
      user = "ec2-user"
      host = self.public_ip 
    }

  }
}

output "ip_address" {
    value = aws_instance.server1.public_ip
}


