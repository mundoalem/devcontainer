# ######################################################################################################################
# LICENSE
# ######################################################################################################################

#
# This file is part of container-dev-base.
#
# The container-dev-base is free software: you can redistribute it and/or modify it under the terms of the GNU Affero
# General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# The container-dev-base is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with container-dev-base. If not, see
# <https://www.gnu.org/licenses/>.
#

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
POLICIES_DIR := $(abspath ${ROOT_DIR}/policies)
SOURCE_DIR := $(abspath ${ROOT_DIR}/src)
TESTS_DIR := $(abspath ${ROOT_DIR}/tests)

#
# Project: General
#

PROJECT_BUILD_DATE ?= $(shell date --rfc-3339=seconds)
PROJECT_COMMIT ?= $(shell git rev-parse HEAD)
PROJECT_NAME ?= $(error PROJECT_NAME is not set)
PROJECT_VERSION ?= $(strip \
	$(if \
		$(shell git rev-list --tags --max-count=1), \
		$(shell git describe --tags `git rev-list --tags --max-count=1`), \
		$(shell git rev-parse --short HEAD) \
	) \
)

#
# Project: Docker
#

PROJECT_DOCKER_BUILDER := builder-$(PROJECT_NAME)
PROJECT_DOCKER_PLATFORMS ?= linux/arm64,linux/amd64
PROJECT_DOCKER_TEST_ARCH ?= arm64
PROJECT_DOCKER_REPOSITORY ?= $(PROJECT_NAME)
PROJECT_DOCKER_SCOUT_SEVERITY ?= critical,high
PROJECT_DOCKER_USER ?= $(warning PROJECT_DOCKER_USER is not set)

#
# Image Arguments
#

DEFAULT_LANG ?= C.UTF-8
DEFAULT_USER_PRIMARY_GROUP ?= developers
DEFAULT_USER_SECONDARY_GROUPS ?= sudo,docker
DEFAULT_USER_SHELL ?= /bin/bash
DEFAULT_USER ?= dev

# ######################################################################################################################
# TARGETS
# ######################################################################################################################

.PHONY: all
all: lint scan build test

.PHONY: build
build:
	@for platform in `echo ${PROJECT_DOCKER_PLATFORMS} | tr ',' ' '`; do \
		arch="$$(echo $$platform | cut -d/ -f2)"; \
		echo "Building $(PROJECT_NAME):$(PROJECT_VERSION)-$$arch"; \
		docker build \
			--build-arg PROJECT_BUILD_DATE="$(PROJECT_BUILD_DATE)" \
			--build-arg PROJECT_COMMIT="$(PROJECT_COMMIT)" \
			--build-arg PROJECT_VERSION="$(PROJECT_VERSION)" \
			--build-arg DEFAULT_LANG="$(DEFAULT_LANG)" \
			--build-arg DEFAULT_USER_PRIMARY_GROUP="$(DEFAULT_USER_PRIMARY_GROUP)" \
			--build-arg DEFAULT_USER_SECONDARY_GROUPS="$(DEFAULT_USER_SECONDARY_GROUPS)" \
			--build-arg DEFAULT_USER_SHELL="$(DEFAULT_USER_SHELL)" \
			--build-arg DEFAULT_USER="$(DEFAULT_USER)" \
			--file "$(SOURCE_DIR)/Dockerfile" \
			--platform "$$platform" \
			--tag "$(PROJECT_NAME):$(PROJECT_VERSION)-$$arch" \
			.; \
	done


.PHONY: clean
clean:
	@for platform in `echo ${PROJECT_DOCKER_PLATFORMS} | tr ',' ' '`; do \
		arch="$$(echo $$platform | cut -d/ -f2)"; \
		echo "Removing $(PROJECT_NAME):$(PROJECT_VERSION)-$$arch"; \
		docker images \
			--quiet \
			"$(PROJECT_NAME):$(PROJECT_VERSION)-$$arch" >/dev/null 2>&1 \
		&& docker rmi \
			--force \
			"$(PROJECT_NAME):$(PROJECT_VERSION)-$$arch" >/dev/null 2>&1; \
		echo "Removing $(PROJECT_NAME)-test:$$arch"; \
		docker images \
			--quiet \
			"$(PROJECT_NAME)-test:$$arch" >/dev/null 2>&1 \
		&& docker rmi \
			--force \
			"$(PROJECT_NAME)-test:$$arch" >/dev/null 2>&1; \
	done

.PHONY: lint
lint:
	@echo "Linting ${SOURCE_DIR}/Dockerfile"
	@hadolint "${SOURCE_DIR}/Dockerfile"
	@echo "Linting ${SOURCE_DIR}/Dockerfile.test"
	@hadolint "${SOURCE_DIR}/Dockerfile.test"

.PHONY: release
release:
	@docker buildx inspect \
		--bootstrap \
		--builder "$(PROJECT_DOCKER_BUILDER)" >/dev/null 2>&1 \
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
		--builder "$(PROJECT_DOCKER_BUILDER)" \
		--file "$(SOURCE_DIR)/Dockerfile" \
		--tag "$(PROJECT_DOCKER_USER)/$(PROJECT_DOCKER_REPOSITORY):$(PROJECT_VERSION)" \
		--tag "$(PROJECT_DOCKER_USER)/$(PROJECT_DOCKER_REPOSITORY):latest" \
		--push \
		.

.PHONY: scan
scan:
	@echo "Scanning $(SOURCE_DIR)/Dockerfile"
	@checkov \
		--file "$(SOURCE_DIR)/Dockerfile" \
		--external-checks-dir "$(POLICIES_DIR)" \
		--framework dockerfile \
		--output cli

.PHONY: reset
reset: clean
	@echo "Removing builder $(PROJECT_DOCKER_BUILDER)"
	@docker buildx inspect \
	    --bootstrap \
		--builder "$(PROJECT_DOCKER_BUILDER)" >/dev/null 2>&1 \
	&& docker buildx rm \
		--builder "$(PROJECT_DOCKER_BUILDER)" \
	|| echo -n ""

.PHONY: test
test:
	@for platform in `echo ${PROJECT_DOCKER_PLATFORMS} | tr ',' ' '`; do \
		arch="$$(echo $$platform | cut -d/ -f2)"; \
		echo "Testing $(PROJECT_NAME)-test:$$arch"; \
		docker build \
			--build-arg PROJECT_VERSION="$(PROJECT_VERSION)-$$arch" \
			--file "$(SOURCE_DIR)/Dockerfile.test" \
			--platform "$$platform" \
			--tag "$(PROJECT_NAME)-test:$$arch" \
			. \
		&& docker run \
			--platform "$$platform" \
			--rm \
			"$(PROJECT_NAME)-test:$$arch"; \
	done
