#!/bin/bash

# NODE
echo "-- INSTALL NODEJS --"
sudo yum install -y openssl-devel
sudo curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs