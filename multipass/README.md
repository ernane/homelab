## Launch VM Master

```bash
multipass launch --name k8s-master --cpus 3 --memory 6G --disk 20G --cloud-init multipass/master/cloud-init-master.yaml -vvv
```

## GET IP Master

```bash
ip_addr=$(multipass info k8s-master | awk '/IPv4/ {print $NF}')
ssh "ubuntu@${ip_addr}"
```

```bash
multipass exec k8s-master -- cat /home/ubuntu/join-node
```

```bash
multipass exec k8s-master -- microk8s add-node --token-ttl 3600
```

```bash
multipass launch --name k8s-worker-01 --cpus 3 --memory 6G --disk 20G --cloud-init multipass/workers/cloud-init-worker.yaml -vvv
```

```bash
multipass launch --name k8s-worker-02 --cpus 3 --memory 6G --disk 20G --cloud-init multipass/workers/cloud-init-worker.yaml -vvv
```

```bash
multipass exec k8s-master -- microk8s kubectl config view --raw > .kube/config/microk8s.yaml
```

```bash
kubectl get pod -A --kubeconfig .kube/config/microk8s.yaml
```

```bash
export KUBECONFIG=.kube/config/microk8s.yaml
```

```bash
kubectl create token default
```

```bash
kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address='0.0.0.0'
```

## Post Install Cluster

```bash
```

```bash
```


https://www.youtube.com/watch?v=buRvk-Atyes
https://amalgjose.com/2021/06/08/how-to-configure-kubernetes-port-forward-bind-to-0-0-0-0-instead-of-default-127-0-0-1/