REPO_PATH := github.com/microkube/micro-kube

# These are the IP and port of the VM.
VM_IP := 172.17.8.100
VM_API_PORT := 8080
# This is a second IP for the VM on the SAME host only network as docker-machine so that
# containerized integration tests that might be running in docker-machine can see the VM.  This is
# used during testing only.
TEST_IP := 192.168.99.254

# The following variables describe the containerized dev / test environment
DEV_ENV_IMAGE := microkube/dev-env:v0.4.0
DEV_ENV_WORK_DIR := /go/src/${REPO_PATH}
DEV_ENV_RUN_ARGS := --rm -e SYSTEM_POD_IP=${VM_IP} -e TEST_IP=${TEST_IP} -e TEST_PORT=${VM_API_PORT} -v ${CURDIR}:${DEV_ENV_WORK_DIR} -w ${DEV_ENV_WORK_DIR}/${DEV_ENV_RELATIVE_WORK_DIR} ${DEV_ENV_IMAGE}
DEV_ENV_CMD := docker run ${DEV_ENV_RUN_ARGS}
DEV_ENV_CMD_INT := docker run -it ${DEV_ENV_RUN_ARGS}

check-vagrant:
	@if [ -z $$(which vagrant) ]; then \
		echo "Missing \`vagrant\`, which is required for testing"; \
		exit 1; \
	fi

check-docker:
	@if [ -z $$(which docker) ]; then \
		echo "Missing \`docker\`, which is required for testing"; \
		exit 1; \
	fi

# Allow developers to step into the containerized dev / test environment
test-env dev-env: check-docker
	${DEV_ENV_CMD_INT} bash

# Pull all go packages that the tests depend upon
test-bootstrap: check-docker
	${DEV_ENV_CMD} bash -c "cd tests && glide install"

test-all: test-bootstrap check-vagrant
	vagrant up
	$(MAKE) wupiao || (vagrant destroy -f && exit 1)
	$(MAKE) test || (vagrant destroy -f && exit 1)
	vagrant destroy -f

test: check-docker
	${DEV_ENV_CMD} go test -v ${REPO_PATH}/tests

wupiao:
	scripts/wupiao.sh ${VM_IP}:${VM_API_PORT} 300
