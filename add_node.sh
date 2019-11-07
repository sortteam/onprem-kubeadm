kubespray_version="2.8.5"

export ANSIBLE_INVALID_TASK_ATTRIBUTE_FAILED=False


### private key 상대경로
PEM_KEY=../SoRT.pem

HOST_FILE='/home/sort-server-1/onprem-kubespray/inventory/mycluster/hosts.ini'
NEW_HOST_FILE='/home/sort-server-1/onprem-kubespray/inventory/mycluster/new_hosts.ini'

echo 'copy host.ini file'
cp ${HOST_FILE} ${NEW_HOST_FILE}

for IP in "$@"
do
	sed -i "/\[all\]/a\ec2-${IP} ansible_host=${IP} ip=${IP} ansible_user=ubuntu" ${NEW_HOST_FILE}
	sed -i "/\[kube-node\]/a\ec2-${IP}" ${NEW_HOST_FILE}
done

cat ${NEW_HOST_FILE}

ansible -m ping --private-key ~/SoRT.pem -i ${NEW_HOST_FILE} -u ubuntu all

if [ $? -eq 0 ]; then
	echo "pass ping test";
else
	echo "raise error while ping test"
	exit 1
fi

ansible-playbook -i ${NEW_HOST_FILE} --private-key ~/SoRT.pem --become --become-user=root kubespray-${kubespray_version}/scale.yml
