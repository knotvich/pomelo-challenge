#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y

wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz 
tar -xvf go1.15.2.linux-amd64.tar.gz  
sudo mv go /usr/local

echo 'export GOPATH=$HOME/go' >> ~/.profile
echo 'export GOROOT=/usr/local/go' >> ~/.profile
echo 'export PATH=$PATH:$GOPATH' >> ~/.profile
echo 'export PATH=$PATH:$GOROOT/bin' >> ~/.profile

source ~/.profile

mkdir ~/go
mkdir ~/go/bin
mkdir ~/go/pkg
mkdir ~/go/src

cd web
go get
go build -o golangnews



