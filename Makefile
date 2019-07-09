# Copyright (C) 2019 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

APP=zeiot

NAMESPACE=$(APP)
IMAGE=gatekeeper

REGISTRY_IMAGE ?= $(NAMESPACE)/$(IMAGE)

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

MAKE_COLOR=\033[33;01m%-35s\033[0m

DOCKER = docker

arch ?= arm

ifneq ($(version),)
	APP_VERSION := $(shell grep ' VERSION' ${version}/Dockerfile.${arch}|awk -F" " '{ print $$3 }')
endif

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo -e "$(OK_COLOR)==== $(APP) [$(APP_VERSION)] ====$(NO_COLOR)"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(MAKE_COLOR) : %s\n", $$1, $$2}'

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo -e "$(ERROR_COLOR)Variable $* not set$(NO_COLOR)"; \
		exit 1; \
	fi

.PHONY: build
build: guard-version guard-arch ## Make the Docker image
	@echo -e "$(OK_COLOR)[$(APP)] build $(REGISTRY_IMAGE):v$(APP_VERSION)-$(arch)$(NO_COLOR)"
	@$(DOCKER) build -t $(REGISTRY_IMAGE):v${APP_VERSION}-$(arch) $(version) -f $(version)/Dockerfile.$(arch)

.PHONY: run
run: guard-arch ## Run the Docker image
	@echo -e "$(OK_COLOR)[$(APP)] run $(REGISTRY_IMAGE):v$(APP_VERSION)-$(arch)$(NO_COLOR)"
	@$(DOCKER) run --rm=true -p 9090:9090 $(REGISTRY_IMAGE):v$(APP_VERSION)-$(arch)

.PHONY: publish-arm
publish: guard-arch ## Publish the Docker image
	@echo -e "$(OK_COLOR)[$(APP)] Publish $(REGISTRY_IMAGE):v$(APP_VERSION)-$(arch)$(NO_COLOR)"
	@$(DOCKER) push $(REGISTRY_IMAGE):v$(APP_VERSION)-$(arch)
