provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Add subnet, Internet Gateway, route table, and EC2 for Jenkins

resource "aws_instance" "jenkins" {
  ami = "ami-0f918f7e67a3323f0" 
  instance_type = "t2.medium"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              sudo usermod -aG docker ec2-user
 	      sudo apt-get update
	      sudo apt-get install fontconfig openjdk-21-jre -y
	      sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  	      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
	      echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  	      https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  	      /etc/apt/sources.list.d/jenkins.list > /dev/null
	      sudo apt-get update -y
	      sudo apt-get install jenkins -y
              EOF
  tags = {
    Name = "Build-Server"
  }
}


# Create security group for EC2 instance
resource "aws_security_group" "Final" {
  name        = "Final"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create security group for EC2 instance
resource "aws_security_group" "Final1" {
  name        = "Final1"
  description = "Allow SSH, HTTP, Jenkins (8080), and MySQL (3306) traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9323
    to_port     = 9323
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}  
# Launch EC2 instance
resource "aws_instance" "BuildEC2" {
  ami             = "ami-0f918f7e67a3323f0" 
  instance_type   = "t2.medium"
  key_name        = "Ec2_wesite"
  vpc_security_group_ids  = [aws_security_group.Final.id]
  tags = {
    Name        = "Jenkins Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install openjdk-21-jre -y
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
                https://pkg.jenkins.io/debian/jenkins.io-2023.key
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update
              sudo apt-get install jenkins -y
              sudo apt install docker.io -y
              sudo chmod 777 /var/run/docker.sock
              EOF
}
