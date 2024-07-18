master:
	@multipass launch --name k8s-master --cpus 3 --memory 6G --disk 20G --cloud-init multipass/master/cloud-init-master.yaml -vvv

pre:
	@kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
	@kubectl wait --namespace metallb-system \
		--for=condition=ready pod \
		--selector=app=metallb \
		--timeout=300s
	@kubectl apply -f manifests/

destroy:
	@multipass stop --all
	@multipass delete --all
	@multipass purge

jenkins-pass:
	@kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo