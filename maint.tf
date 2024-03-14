terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Create Spark cluster

provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0b7282dd7deb48e78"
  instance_type = "t2.micro"

  key_name = var.key_name

  # Add role to the instance
  # iam_instance_profile = "role-ec2-admin"

  tags = {
    Name = "MySparkInstance"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Faire attention, change en fonction des AIM
    private_key = file(var.key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./script.sh"  
    destination = "/tmp/script.sh"  
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh", 
      "/tmp/script.sh" 
    ]
  }
}

# Copy app-py folder in the instance
resource "null_resource" "copy_app" {

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = aws_instance.my_ec2_instance.public_ip
  }

  provisioner "file" {
    source      = "./py/"
    destination = "./"
  }

  # Run the docker-compose file
  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/",
      "docker-compose up --build -d"
    ]
  }
}

# Create monogoDB cluster
resource "aws_instance" "my_mongo_instance" {
  ami           = "ami-0b7282dd7deb48e78"
  instance_type = "t2.micro"

  key_name = var.key_name

  tags = {
    Name = "MyMongoInstance"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "./script.sh"  
    destination = "/tmp/script.sh"  
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh", 
      "/tmp/script.sh" 
    ]
  }
}

resource "null_resource" "copy_app_mongo" {

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = aws_instance.my_mongo_instance.public_ip
  }

  provisioner "file" {
    source      = "./mongoDB/docker-compose.yml"
    destination = "./docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/",
      "docker-compose up --build -d"
    ]
  }

}



output "ec2_instance_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}
