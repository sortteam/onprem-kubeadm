## Install Kubernetes On-Premise

개발 환경 유지보수 를 위해 On-Premise 환경에서 kubernetes 환경을 kubespray로 자동으로 셋업해주는 Ansible 코드입니다.



## Install

1. 모든 노드에 접근할 수 있는 private key(*.pem)파일을 master노드로 옮깁니다.

2. master 노드에 퍼블릭 아이피로 ssh 접속을 합니다.

3. `git clone https://github.com/sortteam/onprem-kubespray && cd onprem-kubespray `

4. `chmod +x install.sh && ./install.sh`

5. `vim inventory.ini` 인벤토리의 `ansible_ssh_host`와 `ip`를 private ip로 수정합니다.

   ```ini
   k8s-master ansible_ssh_host=172.31.40.12 ip=172.31.40.12 ansible_ssh_port=22
   k8s-node1 ansible_ssh_host=172.31.38.205 ip=172.31.38.205 ansible_ssh_port=22
   # 노드를 더 추가하고 싶다면 아래와 같이 설정
   #k8s-node2 ansible_ssh_host=X.X.X.X ip=X.X.X.X ansible_ssh_port=22
   #k8s-node3 ansible_ssh_host=X.X.X.X ip=X.X.X.X ansible_ssh_port=22
   
   [kube-master]
   k8s-master
   
   [etcd]
   k8s-master
   
   [kube-node]
   k8s-node1
   #k8s-node2
   #k8s-node3
   
   [k8s-cluster:children]
   kube-master
   kube-node
   ```

6. 다음 명령어로 모든 노드가 연결되어 있는지 ping test를 합니다. `ansible -m ping --private-key [private-key].pem -i inventory.ini -u ubuntu all -vvv`

7. `ansible-playbook -b --private-key [private-key].pem -i inventory.ini kubespray-2.10.4/cluster.yml -vvv` 로 클러스터링을 진행합니다.

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