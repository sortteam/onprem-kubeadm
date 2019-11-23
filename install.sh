#!/usr/bin/env bash

kubespray_version="2.8.5"

export ANSIBLE_INVALID_TASK_ATTRIBUTE_FAILED=False

sudo apt update && sudo apt install python-pip build-essential python-dev -y
wget https://github.com/kubernetes-sigs/kubespray/archive/v${kubespray_version}.tar.gz
tar zxvf v${kubespray_version}.tar.gz && rm v${kubespray_version}.tar.gz
sudo pip install -r kubespray-${kubespray_version}/requirements.txt

### private key 상대경로
PEM_KEY=../SoRT.pem
### 모든 노드의 private ips
declare -a IPS=(172.16.100.100 172.16.100.101 172.16.100.102)

CONFIG_FILE=inventory/mycluster/hosts.ini python3 kubespray-${kubespray_version}/contrib/inventory_builder/inventory.py ${IPS[@]}
