CURRENT_DIR = $(shell pwd)
CLAB_NAME ?= test_lab
DOCKER_NAME ?= test_clab
USERNAME = avd
USER_UID = $(shell id -u)
USER_GID = $(shell id -g)

.PHONY: help
help: ## Display help message
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build docker image
	docker build --rm --pull --no-cache --build-arg USERNAME=$(USERNAME) --build-arg USER_UID=$(USER_UID) --build-arg USER_GID=$(USER_GID) -t $(DOCKER_NAME):latest -f $(CURRENT_DIR)/.devcontainer/Dockerfile .

.PHONY: clab_graph
clab_graph: ## Build lab graph
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home/$(USERNAME)/projects \
		-v $(CURRENT_DIR):/home/$(USERNAME)/projects \
		-v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro \
		-e AVD_GIT_USER="$(shell git config --get user.name)" \
		-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
		$(DOCKER_NAME):latest sudo containerlab graph --topo $(CLAB_NAME).clab.yml

.PHONY: clab_deploy
clab_deploy: ## Deploy ceos lab
	if [ "${_IN_CONTAINER}" = "True" ]; then \
		sudo containerlab deploy --debug --topo $(CLAB_NAME).clab.yml --max-workers 2 --timeout 5m ;\
	else \
		docker run --rm -it --privileged \
			--network host \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v /etc/hosts:/etc/hosts \
			--pid="host" \
			-w /home/$(USERNAME)/projects \
			-v $(CURRENT_DIR):/home/$(USERNAME)/projects \
			-v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			$(DOCKER_NAME):latest sudo containerlab deploy --debug --topo $(CLAB_NAME).clab.yml --max-workers 2 --timeout 5m ;\
	fi

.PHONY: clab_scale_deploy
clab_scale_deploy: ## Deploy ceos lab
	if [ "${_IN_CONTAINER}" = "True" ]; then \
		sudo containerlab deploy --debug --topo $(CLAB_NAME)_scale.clab.yml --max-workers 2 --timeout 5m ;\
	else \
		docker run --rm -it --privileged \
			--network host \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v /etc/hosts:/etc/hosts \
			--pid="host" \
			-w /home/$(USERNAME)/projects \
			-v $(CURRENT_DIR):/home/$(USERNAME)/projects \
			-v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			$(DOCKER_NAME):latest sudo containerlab deploy --debug --topo $(CLAB_NAME)_scale.clab.yml --max-workers 2 --timeout 5m ;\
	fi

.PHONY: clab_destroy
clab_destroy: ## Destroy ceos lab
	if [ "${_IN_CONTAINER}" = "True" ]; then \
		sudo containerlab destroy --debug --topo $(CLAB_NAME).clab.yml --cleanup ; \
	else \
		docker run --rm -it --privileged \
			--network host \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v /etc/hosts:/etc/hosts \
			--pid="host" \
			-w /home/$(USERNAME)/projects \
			-v $(CURRENT_DIR):/home/$(USERNAME)/projects \
			-v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			test_clab:latest sudo containerlab destroy --debug --topo $(CLAB_NAME).clab.yml --cleanup ; \
	fi

.PHONY: clab_scale_destroy
clab_scale_destroy: ## Destroy ceos lab
	if [ "${_IN_CONTAINER}" = "True" ]; then \
		sudo containerlab destroy --debug --topo $(CLAB_NAME)_scale.clab.yml --cleanup ; \
	else \
		docker run --rm -it --privileged \
			--network host \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v /etc/hosts:/etc/hosts \
			--pid="host" \
			-w /home/$(USERNAME)/projects \
			-v $(CURRENT_DIR):/home/$(USERNAME)/projects \
			-v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro \
			-e AVD_GIT_USER="$(shell git config --get user.name)" \
			-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
			$(DOCKER_NAME):latest sudo containerlab destroy --debug --topo $(CLAB_NAME)_scale.clab.yml --cleanup ; \
	fi

.PHONY: run
run: ## run docker image
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home/$(USERNAME)/projects \
		-v $(CURRENT_DIR):/home/$(USERNAME)/projects \
		-v $(CURRENT_DIR)/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro \
		-e AVD_GIT_USER="$(shell git config --get user.name)" \
		-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
		$(DOCKER_NAME):latest || true

.PHONY: test
test: ## some random tests
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home/$(USERNAME)/projects \
		-v $(CURRENT_DIR):/home/$(USERNAME)/projects \
		-v /etc/sysctl.d/99-zceos.conf:/etc/sysctl.d/99-zceos.conf:ro \
		-e AVD_GIT_USER="$(shell git config --get user.name)" \
		-e AVD_GIT_EMAIL="$(shell git config --get user.email)" \
		$(DOCKER_NAME):latest cat /etc/sysctl.d/99-zceos.conf
