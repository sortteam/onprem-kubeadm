#!/bin/bash
set -v
kubespray_version="2.8.5"

export ANSIBLE_INVALID_TASK_ATTRIBUTE_FAILED=False


### private key 상대경로
PEM_KEY=./SoRT.pem

KUBESPRAY_DIR=~/onprem-kubespray

HOST_FILE='/home/sort-server-1/onprem-kubespray/inventory/mycluster/hosts.ini'
NEW_HOST_FILE='/home/sort-server-1/onprem-kubespray/inventory/mycluster/new_hosts.ini'

declare -a VPN_IP_LIST=()


echo "Input IP is : ${@}"

# copy ovpn file
for IP in "$@"
do
  ssh-copy-id -o StrictHostKeyChecking=no ${IP}
	scp -i $PEM_KEY ~/ywj-client.ovpn ubuntu@${IP}:~/ 
	scp -i $PEM_KEY $KUBESPRAY_DIR/fix_routes.sh ubuntu@${IP}:~/
	scp -i $PEM_KEY $KUBESPRAY_DIR/ec2_run.sh ubuntu@${IP}:~/
  
  # sudo scp -i $PEM_KEY -r /etc/calico/certs ubuntu@${IP}:~/certs
  ssh -i $PEM_KEY ubuntu@${IP} 'sudo cp -r ~/certs /etc/calico/certs'
  
	ssh -i $PEM_KEY ubuntu@${IP} 'sudo ln -s /usr/bin/python3.6 /usr/bin/python'
  if [ -z $(ssh -i $PEM_KEY ubuntu@${IP} 'ifconfig | grep tun0') ];then
    ssh -i $PEM_KEY ubuntu@${IP} './ec2_run.sh' &
	  sleep 20
    VPN_IP_LIST+=("$(ssh -i $PEM_KEY ubuntu@${IP} ifconfig tun0 | grep '\(destination\)' | cut -f2 | awk '{ print $2}' )")
  else
    sleep 5
    echo "TEST : $(ssh -i $PEM_KEY ubuntu@${IP} ifconfig tun0 | grep '\(destination\)' | cut -f2 | awk '{ print $2}' )"
    VPN_IP_LIST+=("$(ssh -i $PEM_KEY ubuntu@${IP} ifconfig tun0 | grep '\(destination\)' | cut -f2 | awk '{ print $2}' )")
  fi
  echo "${IP} -> ${VPN_IP_LIST[@]}"
done


echo "VPN client IP list : (${VPN_IP_LIST[@]})"

echo 'copy host.ini file'
cp ${HOST_FILE} ${NEW_HOST_FILE}

sleep 5

for IP in "${VPN_IP_LIST[@]}"
do
	sed -i "/\[all\]/a\ec2-${IP//./-} ansible_host=${IP}  ansible_user=ubuntu" ${NEW_HOST_FILE}
	sed -i "/\[kube-node\]/a\ec2-${IP//./-}" ${NEW_HOST_FILE}
done

cat ${NEW_HOST_FILE}

ansible -m ping --private-key ~/SoRT.pem -i ${NEW_HOST_FILE} -u ubuntu all

if [ $? -eq 0 ]; then
	echo "pass ping test";
else
	echo "raise error while ping test"
	exit 1
fi

ansible-playbook -i ${NEW_HOST_FILE} --private-key ~/SoRT.pem --become --become-user=root kubespray-${kubespray_version}/scale.yml -c paramiko

for IP in "$@"
do
  ssh -i $PEM_KEY ubuntu@${IP} 'sudo sed -i "s/localhost/10.8.0.1/" /etc/kubernetes/kubelet.conf'
  ssh -i $PEM_KEY ubuntu@${IP} 'sudo service kubelet restart'
done

for IP in "${VPN_IP_LIST}"
do
  kubectl label nodes ec2-${IP//./-} cloud-type=aws
done
