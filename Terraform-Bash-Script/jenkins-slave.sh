#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y

##Docker installation
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins 
sudo chmod 777 /var/run/docker.sock