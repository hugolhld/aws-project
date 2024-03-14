terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
    region = "eu-west-3"
}

# Check if MyInstance exists by name and instance is running
data "aws_instance" "MySparkInstance_existing" {

    # instance_state = "running"
    instance_tags = {
      Name = "MySparkInstance"
    }

    filter {
        name = "instance-state-name"
        values = ["running"]
    }


}

# If MyInstance exists, return its public IP
output "MyInstancePublicIp" {
    value = data.aws_instance.MySparkInstance_existing.public_ip
}