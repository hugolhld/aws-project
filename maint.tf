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

# Créer un rôle IAM pour l'accès à CloudWatch
resource "aws_iam_role" "cloudwatch_role" {
  name = "cloudwatch_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attacher une politique pour l'accès à CloudWatch au rôle IAM
resource "aws_iam_policy_attachment" "cloudwatch_policy_attachment" {
  name       = "cloudwatch_policy_attachment"
  roles      = [aws_iam_role.cloudwatch_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}




# Check if MyInstance exists by name and instance is running
data "aws_instances" "MySparkInstance_existing" {

    # instance_state = "running"
    instance_tags = {
      Name = "MySparkInstance"
    }

    filter {
        name = "instance-state-name"
        values = ["running"]
    }

}

resource "aws_instance" "my_ec2_instance" {

  count = length(data.aws_instances.MySparkInstance_existing.ids) > 0 ? 0 : 1

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
  count = length(data.aws_instances.MySparkInstance_existing.ids) > 0 ? 0 : 1
  depends_on = [ aws_instance.my_ec2_instance ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = aws_instance.my_ec2_instance[0].public_ip
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

# If MyInstance exists, update file and run the docker-compose file
resource "null_resource" "update_spark_app" {
  count = length(data.aws_instances.MySparkInstance_existing.ids) > 0 ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = data.aws_instances.MySparkInstance_existing.public_ips[0]
  }

  provisioner "file" {
    source      = "./py/"
    destination = "./"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/",
      "docker-compose up --build -d"
    ]
  }
}

# Create monogoDB cluster

# Check if MyInstance exists by name and instance is running
data "aws_instances" "MyMongoInstance_existing" {

    # instance_state = "running"
    instance_tags = {
      Name = "MyMongoInstance"
    }

    filter {
        name = "instance-state-name"
        values = ["running"]
    }
}

resource "aws_instance" "my_mongo_instance" {

  count = length(data.aws_instances.MyMongoInstance_existing.ids) > 0 ? 0 : 1

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

  count = length(data.aws_instances.MyMongoInstance_existing.ids) > 0 ? 0 : 1

  depends_on = [ aws_instance.my_mongo_instance ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = aws_instance.my_mongo_instance[0].public_ip
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

# If MyInstance exists, update file and run the docker-compose file
resource "null_resource" "update_mongo_app" {
  count = length(data.aws_instances.MyMongoInstance_existing.ids) > 0 ? 1 : 0

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = data.aws_instances.MyMongoInstance_existing.public_ips[0]
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

# output "ec2_instance_public_ip" {
#   value = aws_instance.my_ec2_instance.public_ip
# }
