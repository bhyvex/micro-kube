export GO15VENDOREXPERIMENT=1
export MK_IP=172.17.8.100
export MK_PORT=8080

REPO_PATH := github.com/krancour/micro-kube

check-vagrant:
	@if [ -z $$(which vagrant) ]; then \
		echo "Missing \`vagrant\`, which is required for testing"; \
		exit 1; \
	fi

check-go:
	@if [ -z $$(which go) ]; then \
		echo "Missing \`go\`, which is required for testing"; \
		exit 1; \
	fi

check-glide:
	@if [ -z $$(which glide) ]; then \
		echo "Missing \`glide\`, which is required for testing"; \
		exit 1; \
	fi

test-all: check-glide check-vagrant
	glide install
	vagrant up
	scripts/wupiao.sh ${MK_IP}:${MK_PORT} 300 || (vagrant destroy -f && exit 1)
	$(MAKE) test || (vagrant destroy -f && exit 1)
	vagrant destroy -f

test: check-go
	go test --cover --race -v ${REPO_PATH}
