#!/usr/bin/env bash

kubespray_version="2.10.4"

sudo apt update && sudo apt install python-pip build-essential python-dev -y
sudo pip install -r requirements.txt
wget https://github.com/kubernetes-sigs/kubespray/archive/v${kubespray_version}.tar.gz
tar zxvf v${kubespray_version}.tar.gz