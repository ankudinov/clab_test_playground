CURRENT_DIR = $(shell pwd)
CLAB_NAME ?= test_lab
DOCKER_NAME ?= test_clab
_UID = $(shell id -u)
_GID = $(shell id -g)

.PHONY: help
help: ## Display help message
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build docker image
	docker build --rm --pull --no-cache --build-arg _UID=$(_UID) --build-arg _GID=$(_GID) -t $(DOCKER_NAME):latest -f $(CURRENT_DIR)/.devcontainer/Dockerfile .

# .PHONY: clab_deploy
# clab_deploy: ## Deploy ceos lab
# 	containerlab deploy --topo $(CLAB_NAME).clab.yml

# .PHONY: clab_destroy
# clab_destroy: ## Destroy ceos lab
# 	containerlab destroy --topo $(CLAB_NAME).clab.yml --cleanup

# .PHONY: clab_graph
# clab_graph: ## Build lab graph
# 	containerlab graph --topo $(CLAB_NAME).clab.yml

.PHONY: clab_deploy
clab_deploy: ## Deploy ceos lab
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home \
		-v $(CURRENT_DIR):/home \
		$(DOCKER_NAME):latest containerlab deploy --debug --topo $(CLAB_NAME).clab.yml --max-workers 2 --timeout 5m

.PHONY: clab_direct_deploy
clab_direct_deploy: ## Deploy ceos lab
	sudo containerlab deploy --debug --topo $(CLAB_NAME).clab.yml --max-workers 2 --timeout 5m

.PHONY: clab_scale_deploy
clab_scale_deploy: ## Deploy ceos lab
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home \
		-v $(CURRENT_DIR):/home \
		$(DOCKER_NAME):latest containerlab deploy --debug --topo $(CLAB_NAME)_scale.clab.yml --max-workers 2 --timeout 5m

.PHONY: clab_direct_scale_deploy
clab_direct_scale_deploy: ## Deploy ceos lab
	sudo containerlab deploy --debug --topo $(CLAB_NAME)_scale.clab.yml --max-workers 2 --timeout 5m

.PHONY: clab_destroy
clab_destroy: ## Destroy ceos lab
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home \
		-v $(CURRENT_DIR):/home \
		test_clab:latest containerlab destroy --debug --topo $(CLAB_NAME).clab.yml --cleanup

.PHONY: clab_scale_destroy
clab_scale_destroy: ## Destroy ceos lab
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home \
		-v $(CURRENT_DIR):/home \
		$(DOCKER_NAME):latest containerlab destroy --debug --topo $(CLAB_NAME)_scale.clab.yml --cleanup

.PHONY: clab_interactive
clab_interactive: ## start interactive clab container
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home \
		-v $(CURRENT_DIR):/home \
		$(DOCKER_NAME):latest bash

.PHONY: run
run: ## run docker image
	docker run --rm -it --privileged \
		--network host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /etc/hosts:/etc/hosts \
		--pid="host" \
		-w /home \
		-v $(CURRENT_DIR):/home \
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
		-w /home \
		-v $(CURRENT_DIR):/home \
		$(DOCKER_NAME):latest echo "\ntest" >> /etc/hosts
