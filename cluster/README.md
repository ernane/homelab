# Kubernetes Cluster

## Criação das VMs

```sh
vagrant up
```

## Atualizações dos Pacotes

```sh
sudo apt update -y ; sudo apt dist-upgrade -y ; sudo apt autoclean -y ; sudo apt autoremove -y
```

## Enable IPv4 packet forwarding

> To manually enable IPv4 packet forwarding:

```sh
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

## Verify that net.ipv4.ip_forward is set to 1 with:

```sh
sysctl net.ipv4.ip_forward
```

## Install using the apt repository

> Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.

### Set up Docker's apt repository

```sh
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### Install the Docker packages

> To install the latest version, run:

```sh
sudo apt-get update ; sudo apt-get install containerd.io -y
```

## Configuration containerd

> Assume root user

```sh
sudo su
```

### Export config default

```sh
containerd config default > /etc/containerd/config.toml ; systemctl restart containerd ; systemctl status containerd
```

## Swap memory management

> view fstab

```sh
cat /etc/fstab
```

### disable swapping

> disable swapping temporarily

```sh
swapoff -a ; cat /proc/swaps
```

## Installing kubeadm, kubelet and kubectl

> Update the apt package index and install packages needed to use the Kubernetes apt repository:

```sh
sudo apt-get update ; sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

> Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:

```sh
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

> Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.30; for other Kubernetes minor versions, you need to change the Kubernetes minor version in the URL to match your desired minor version (you should also check that you are reading the documentation for the version of Kubernetes that you plan to install).

```sh
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

> Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:

```sh
sudo apt-get update ; sudo apt-get install -y kubelet kubeadm kubectl ; sudo apt-mark hold kubelet kubeadm kubectl
```

## Creating a cluster with kubeadm

> Initializing your control-plane node

```sh
kubeadm init --apiserver-advertise-address 192.168.57.10 --pod-network-cidr 10.244.0.0/16
```

### Add node

> You can now join any number of machines by running the following on each node as root: kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>

```sh
kubeadm join 192.168.57.10:6443 --token 3hm1as.top9qrhfx7m0oqrs --discovery-token-ca-cert-hash sha256:777da99846e3b31bf8ddc9f43e8f8c6f8b40e9ba50d241c11e6b6ea699beda91
```

## Flannel

```sh
k apply -f manifests/kube-flannel.yml
```

## kubelet

```sh
vim /etc/default/kubelet

KUBELET_EXTRA_ARGS=--node-ip=192.168.57.10
KUBELET_EXTRA_ARGS=--node-ip=192.168.57.20
KUBELET_EXTRA_ARGS=--node-ip=192.168.57.30
```

```sh
systemctl daemon-reload ; systemctl restart kubelet ; ps aux | grep kubelet
```