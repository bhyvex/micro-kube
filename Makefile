SERVER := 172.17.8.100:8080

check-vagrant:
	@if [ -z $$(which vagrant) ]; then \
		echo "Missing \`vagrant\`, which is required for development"; \
		exit 1; \
	fi

check-kubectl:
	@if [ -z $$(which kubectl) ]; then \
		echo "Missing \`kubectl\`, which is required for development"; \
		exit 1; \
	fi

up: check-vagrant
	vagrant up

destroy: check-vagrant
	vagrant destroy -f

config-kubectl: check-kubectl
	kubectl config set-cluster micro-kube-insecure --server=http://${SERVER}
	kubectl config set-context micro-kube-insecure --cluster=micro-kube-insecure
	kubectl config use-context micro-kube-insecure

test: check-vagrant check-kubectl up config-kubectl
	@./_scripts/wupiao.sh ${SERVER} 300 || ($(MAKE) destroy && exit 1)
	@$(MAKE) destroy
