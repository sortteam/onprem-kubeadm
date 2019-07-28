## Install Kubernetes On-Premise

개발 환경 유지보수 를 위해 On-Premise 환경에서 kubernetes 환경을 kubespray로 자동으로 셋업해주는 Ansible 코드입니다.



## Install

1. 모든 노드에 접근할 수 있는 private key(*.pem)파일을 master노드로 옮깁니다.

   ```shell
   $ scp -i Sort.pem Sort.pem ubuntu@<public_ip>:/home/ubuntuk
   ```

2. master 노드에 퍼블릭 아이피로 ssh 접속을 합니다.

3. `git clone https://github.com/sortteam/onprem-kubespray && cd onprem-kubespray `

4. `install.sh`의 아래 부분을 수정합니다.

   ```shell
   ### private key 상대경로
   PEM_KEY=../SoRT.pem
   ### 모든 노드의 private ips
   declare -a IPS=(172.31.36.56 172.31.46.134)
   ```

5. `chmod +x install.sh && ./install.sh`

6. `inventory/mycluster/hosts.ini`의 아래 private ip부분을 수정합니다.

   ```ini
   [all]
   node1 	 ansible_host=172.31.36.56 ip=172.31.36.56
   node2 	 ansible_host=172.31.46.134 ip=172.31.46.134
   #node3 	 ansible_host=172.31.46.134 ip=172.31.46.134
   
   [kube-master]
   node1
   
   [etcd]
   node1
   
   [kube-node]
   node2
   #node3
   
   [k8s-cluster:children]
   kube-master 	 
   kube-node
   ```

7. 다음 명령어로 모든 노드가 연결되어 있는지 ping test를 합니다. `ansible -m ping --private-key ../SoRT.pem -i inventory/mycluster/hosts.ini -u ubuntu all -vvv`

8. `export ANSIBLE_INVALID_TASK_ATTRIBUTE_FAILED=False`

9. `ansible-playbook -i inventory/mycluster/hosts.ini --private-key ../SoRT.pem --become --become-user=root kubespray-2.8.5/cluster.yml` 로 클러스터링을 진행합니다.

```shell
ubuntu@ip-172-31-40-12:~$ kubectl get nodes
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   4m55s   v1.14.3
k8s-node1    Ready    <none>   4m18s   v1.14.3
```



### The connection to the server localhost:8080 was refused 오류 시

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```



## requirements

- ubuntu>=16.04
- ansible>=2.7.8
- jinja2>=2.9.6
- netaddr
- pbr>=1.6
- hvac>=0.9.5