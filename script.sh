#!/bin/bash

# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Start docker
sudo service docker start

# Add ec-user to docker group
sudo usermod -a -G docker ec2-user

# Instal git
sudo yum install -y git

git clone https://github.com/docker/compose.git /tmp/docker-compose

sudo cp /tmp/docker-compose/bin/docker-compose /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sudo mkdir -p /opt/docker-compose

sudo chown -R ec2-user:ec2-user /opt/docker-compose

sudo chmod -R 775 /opt/docker-compose

sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null

sudo chmod +x /usr/local/bin/docker-compose

ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

docker-compose --version 

exit