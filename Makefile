# ######################################################################################################################
#
# This file is part of container-dev-base.
#
# The container-dev-base is free software: you can redistribute it and/or modify it under the terms
# of the GNU Affero General Public License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.
#
# The container-dev-base is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with
# container-dev-base. If not, see <https://www.gnu.org/licenses/>.
#
# ######################################################################################################################

# ######################################################################################################################
# VARIABLES
# ######################################################################################################################

#
# Make
#

SHELL := /bin/bash

#
# Directories
#

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CONFIG_DIR := $(abspath ${ROOT_DIR}/config)
POLICIES_DIR := $(abspath ${ROOT_DIR}/policies)
SOURCE_DIR := $(abspath ${ROOT_DIR}/src)
TESTS_DIR := $(abspath ${ROOT_DIR}/tests)

#
# Project: General
#

PROJECT_BUILD_DATE ?= $(shell date --rfc-3339=seconds)
PROJECT_COMMIT ?= $(shell git rev-parse HEAD)
PROJECT_NAME ?= $(error PROJECT_NAME is not set)
PROJECT_VERSION ?= $(if $(shell git rev-list --tags --max-count=1), $(shell git describe --tags `git rev-list --tags --max-count=1`), $(shell git rev-parse --short HEAD))

#
# Project: Docker
#

PROJECT_DOCKER_BUILDER := builder-$(PROJECT_NAME)
PROJECT_DOCKER_PASSWORD ?= $(warning PROJECT_DOCKER_PASSWORD is not set)
PROJECT_DOCKER_PLATFORMS ?= linux/arm64,linux/amd64
PROJECT_DOCKER_TEST_ARCH ?= arm64
PROJECT_DOCKER_REPOSITORY ?= $(PROJECT_NAME)
PROJECT_DOCKER_SERVER ?=
PROJECT_DOCKER_USER ?= $(warning PROJECT_DOCKER_USER is not set)

#
# Image Arguments
#

DEFAULT_LANG ?= C.UTF-8
DEFAULT_USER_PRIMARY_GROUP ?= developers
DEFAULT_USER_SECONDARY_GROUPS ?= sudo,docker
DEFAULT_USER_SHELL ?= /bin/bash
DEFAULT_USER ?= mundoalem
DEFAULT_WORKSPACE_DIR ?= /workspaces

# ######################################################################################################################
# TARGETS
# ######################################################################################################################

all: lint build scan test

.PHONY: build
build:
	@for platform in $${PROJECT_DOCKER_PLATFORMS//,/ }; do \
		arch="$$(echo $$platform | cut -d/ -f2)"; \
		docker build \
			--build-arg PROJECT_BUILD_DATE="$(PROJECT_BUILD_DATE)" \
			--build-arg PROJECT_COMMIT="$(PROJECT_COMMIT)" \
			--build-arg PROJECT_VERSION="$(PROJECT_VERSION)" \
			--build-arg DEFAULT_LANG="$(DEFAULT_LANG)" \
			--build-arg DEFAULT_USER_PRIMARY_GROUP="$(DEFAULT_USER_PRIMARY_GROUP)" \
			--build-arg DEFAULT_USER_SECONDARY_GROUPS="$(DEFAULT_USER_SECONDARY_GROUPS)" \
			--build-arg DEFAULT_USER_SHELL="$(DEFAULT_USER_SHELL)" \
			--build-arg DEFAULT_USER="$(DEFAULT_USER)" \
			--build-arg DEFAULT_WORKSPACE_DIR="$(DEFAULT_WORKSPACE_DIR)" \
			--file "$(SOURCE_DIR)/Dockerfile" \
			--platform "$$platform" \
			--tag "$(PROJECT_NAME):$(PROJECT_VERSION)-$$arch" \
			.; \
	done

.PHONY: clean
clean:
	@docker rmi "$(PROJECT_NAME)"

.PHONY: lint
lint:
	@hadolint "$(SOURCE_DIR)/Dockerfile"

.PHONY: release
release: 
	@echo "$(PROJECT_DOCKER_PASSWORD)" \
	| docker login \
		--username "$(PROJECT_DOCKER_USER)" \
		--password-stdin \
		$(PROJECT_DOCKER_SERVER)

	@docker buildx inspect \
		--bootstrap \
		--builder "$(PROJECT_DOCKER_BUILDER)" 2>&1 >/dev/null \
	|| docker buildx create \
		--bootstrap \
		--name "$(PROJECT_DOCKER_BUILDER)" \
		--platform "$(PROJECT_DOCKER_PLATFORMS)" \
		--use

	@docker buildx build \
		--build-arg PROJECT_BUILD_DATE="$(PROJECT_BUILD_DATE)" \
		--build-arg PROJECT_COMMIT="$(PROJECT_COMMIT)" \
		--build-arg PROJECT_VERSION="$(PROJECT_VERSION)" \
		--build-arg DEFAULT_LANG="$(DEFAULT_LANG)" \
		--build-arg DEFAULT_USER_PRIMARY_GROUP="$(DEFAULT_USER_PRIMARY_GROUP)" \
		--build-arg DEFAULT_USER_SECONDARY_GROUPS="$(DEFAULT_USER_SECONDARY_GROUPS)" \
		--build-arg DEFAULT_USER_SHELL="$(DEFAULT_USER_SHELL)" \
		--build-arg DEFAULT_USER="$(DEFAULT_USER)" \
		--build-arg DEFAULT_WORKSPACE_DIR="$(DEFAULT_WORKSPACE_DIR)" \
		--builder "$(PROJECT_DOCKER_BUILDER)" \
		--file "$(SOURCE_DIR)/Dockerfile" \
		--tag "$(PROJECT_DOCKER_USER)/$(PROJECT_DOCKER_REPOSITORY):$(PROJECT_VERSION)" \
		--tag "$(PROJECT_DOCKER_USER)/$(PROJECT_DOCKER_REPOSITORY):latest" \
		--push \
		.

.PHONY: reset
reset: clean
	@docker buildx inspect \
		--bootstrap \
		--builder "$(PROJECT_DOCKER_BUILDER)" 2>&1 >/dev/null \
	|| docker buildx rm \
		--builder "$(PROJECT_DOCKER_BUILDER)"

.PHONY: scan
scan:
	@checkov \
		--file "$(SOURCE_DIR)/Dockerfile" \
		--external-checks-dir "$(POLICIES_DIR)" \
		--framework dockerfile \
		--skip-check CKV2_DOCKER_1 \
		--output cli

.PHONY: test
test: build
	@container-structure-test test \
		--image "$(PROJECT_NAME):$(PROJECT_VERSION)-$(PROJECT_DOCKER_TEST_ARCH)" \
		--config "$(TESTS_DIR)/tests.yaml"
