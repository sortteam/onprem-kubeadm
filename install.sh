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
declare -a IPS=(172.31.36.56 172.31.46.134)

for i in ${IPS[@]}
do
  ssh -i $PEM_KEY $i "sudo swapoff -a"
done

