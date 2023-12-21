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
# PRELUDE
# ######################################################################################################################

#
# CHECKOV
#

# This is a container intended to be used as a remote development environment, we want to allow the user the ability to
# become root
#checkov:skip=CKV2_DOCKER_1:Ensure that sudo isn't used

# ----------------------------------------------------------------------------------------------------------------------
# BASE IMAGE
# ----------------------------------------------------------------------------------------------------------------------

FROM ubuntu:23.04

# ----------------------------------------------------------------------------------------------------------------------
# ARGUMENTS
# ----------------------------------------------------------------------------------------------------------------------

#
# DOCKER BUILDKIT
#

ARG BUILDARCH
ARG BUILDOS
ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG TARGETPLATFORM

#
# PROJECT
#

ARG PROJECT_BUILD_DATE
ARG PROJECT_COMMIT
ARG PROJECT_VERSION

#
# IMAGE
#

ARG DEFAULT_LANG="C.UTF-8"
ARG DEFAULT_USER_PRIMARY_GROUP="developers"
ARG DEFAULT_USER_SECONDARY_GROUPS="sudo,docker"
ARG DEFAULT_USER_SHELL="/bin/bash"
ARG DEFAULT_USER="dev"

# ----------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# ----------------------------------------------------------------------------------------------------------------------

#
# OS
#

ENV VERSION_UBUNTU="23.04"
ENV VERSION_UBUNTU_NAME="lunar"

# ----------------------------------------------------------------------------------------------------------------------
# LABELS
# ----------------------------------------------------------------------------------------------------------------------

#
# REFERENCE
#
#   - https://github.com/opencontainers/image-spec/blob/main/annotations.md
#

LABEL org.opencontainers.artifact.created="${PROJECT_BUILD_DATE}"
LABEL org.opencontainers.artifact.description="Base container image to be used as a development environment inside Visual Studio Code"
LABEL org.opencontainers.image.authors="Egon Braun <egon@mundoalem.io>"
LABEL org.opencontainers.image.base.digest="51e70689b125fcc2e800f5efb7ba465dee85ede9da9c268ff5599053c7e52b77"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:${VERSION_UBUNTU}"
LABEL org.opencontainers.image.created="${PROJECT_BUILD_DATE}"
LABEL org.opencontainers.image.description="Base container image to be used as a development environment inside Visual Studio Code"
LABEL org.opencontainers.image.documentation="https://hub.docker.com/r/mundoalemio/dev-base"
LABEL org.opencontainers.image.licenses="AGPLv3"
LABEL org.opencontainers.image.revision="${PROJECT_COMMIT}"
LABEL org.opencontainers.image.source="https://github.com/mundoalem/container-dev-base"
LABEL org.opencontainers.image.title="dev-base"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/mundoalemio/dev-base"
LABEL org.opencontainers.image.vendor="Mundoalem"
LABEL org.opencontainers.image.version="${PROJECT_VERSION}"

# ######################################################################################################################
# SETUP: BASE
# ######################################################################################################################

SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL SYSTEM PACKAGES
# ----------------------------------------------------------------------------------------------------------------------

RUN export DEBIAN_FRONTEND="noninteractive" \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    direnv \
    git \
    git-extras \
    gnupg2 \
    gpg-agent \
    locales \
    lsb-release \
    lsd \
    make \
    pkg-config \
    python3 \
    python3-full \
    pipx \
    software-properties-common \
    ssh \
    sudo \
    unzip \
    && apt-get autoremove -y \
    && apt-get clean autoclean -y \
    && rm -r /var/cache/* /var/lib/apt/lists/*

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE LOCALISATION
# ----------------------------------------------------------------------------------------------------------------------

RUN locale-gen "${DEFAULT_LANG}" \
    && update-locale LANG="${DEFAULT_LANG}"

# ######################################################################################################################
# SETUP: CUSTOM (AS ROOT)
# ######################################################################################################################

#
# Empty
#

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL DOCKER
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_DOCKER_CLI="24.0.7-1"
ENV VERSION_DOCKER_BUILDX_PLUGIN="0.11.2-1"
ENV VERSION_DOCKER_COMPOSE_PLUGIN="2.21.0-1"
ENV VERSION_DOCKER_SCOUT="1.0.9"
ENV FILENAME_DOCKER_SUFFIX="ubuntu.${VERSION_UBUNTU}~${VERSION_UBUNTU_NAME}_${TARGETARCH}.deb"
ENV FILENAME_DOCKER_CLI="docker-ce-cli_${VERSION_DOCKER_CLI}~${FILENAME_DOCKER_SUFFIX}"
ENV FILENAME_DOCKER_BUILDX_PLUGIN="docker-buildx-plugin_${VERSION_DOCKER_BUILDX_PLUGIN}~${FILENAME_DOCKER_SUFFIX}"
ENV FILENAME_DOCKER_COMPOSE_PLUGIN="docker-compose-plugin_${VERSION_DOCKER_COMPOSE_PLUGIN}~${FILENAME_DOCKER_SUFFIX}"
ENV FILENAME_DOCKER_SCOUT_PLUGIN="docker-scout_${VERSION_DOCKER_SCOUT}_linux_${TARGETARCH}.tar.gz"
ENV URL_DOCKER_BASE="https://download.docker.com/linux/ubuntu/dists/${VERSION_UBUNTU_NAME}/pool/stable/${TARGETARCH}"
ENV URL_DOCKER_CLI="${URL_DOCKER_BASE}/${FILENAME_DOCKER_CLI}"
ENV URL_DOCKER_BUILDX_PLUGIN="${URL_DOCKER_BASE}/${FILENAME_DOCKER_BUILDX_PLUGIN}"
ENV URL_DOCKER_COMPOSE_PLUGIN="${URL_DOCKER_BASE}/${FILENAME_DOCKER_COMPOSE_PLUGIN}"
ENV URL_DOCKER_SCOUT_PLUGIN="https://github.com/docker/scout-cli/releases/download/v${VERSION_DOCKER_SCOUT}/${FILENAME_DOCKER_SCOUT_PLUGIN}"

#
# INSTALL
#

RUN curl -sSL -o "/tmp/${FILENAME_DOCKER_CLI}" "${URL_DOCKER_CLI}" \
    && curl -sSL -o "/tmp/${FILENAME_DOCKER_BUILDX_PLUGIN}" "${URL_DOCKER_BUILDX_PLUGIN}" \
    && curl -sSL -o "/tmp/${FILENAME_DOCKER_COMPOSE_PLUGIN}" "${URL_DOCKER_COMPOSE_PLUGIN}" \
    && curl -sSL -o "/tmp/${FILENAME_DOCKER_SCOUT_PLUGIN}" "${URL_DOCKER_SCOUT_PLUGIN}" \
    && dpkg -i "/tmp/${FILENAME_DOCKER_CLI}" \
    && dpkg -i "/tmp/${FILENAME_DOCKER_BUILDX_PLUGIN}" \
    && dpkg -i "/tmp/${FILENAME_DOCKER_COMPOSE_PLUGIN}" \
    && tar xvf "/tmp/${FILENAME_DOCKER_SCOUT_PLUGIN}" -C /usr/libexec/docker/cli-plugins/ docker-scout \
    && groupadd docker \
    && rm -f "/tmp/"*"${FILENAME_DOCKER_SUFFIX}" \
    && rm -f "/tmp/${FILENAME_DOCKER_SCOUT_PLUGIN}"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL HADOLINT
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_HADOLINT="2.12.0"
ENV URL_HADOLINT="https://github.com/hadolint/hadolint/releases/download/v${VERSION_HADOLINT}/hadolint-Linux-${TARGETARCH}"

#
# INSTALL
#

RUN curl -sSL -o /usr/local/bin/hadolint "${URL_HADOLINT}" \
    && chmod +x /usr/local/bin/hadolint

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL GIT DELTA
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_GIT_DELTA="0.16.5"
ENV FILENAME_GIT_DELTA="git-delta_${VERSION_GIT_DELTA}_${TARGETARCH}.deb"
ENV URL_GIT_DELTA_BASE="https://github.com/dandavison/delta/releases/download/${VERSION_GIT_DELTA}"
ENV URL_GIT_DELTA="${URL_GIT_DELTA_BASE}/${FILENAME_GIT_DELTA}"

#
# INSTALL
#

RUN curl -sSL --http1.1 -o "/tmp/${FILENAME_GIT_DELTA}" "${URL_GIT_DELTA}" \
    && dpkg -i "/tmp/${FILENAME_GIT_DELTA}" \
    && rm -f "/tmp/${FILENAME_GIT_DELTA}"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL STARSHIP
# ----------------------------------------------------------------------------------------------------------------------

RUN curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

# ----------------------------------------------------------------------------------------------------------------------
# CREATE DEV USER
# ----------------------------------------------------------------------------------------------------------------------

RUN groupadd "${DEFAULT_USER_PRIMARY_GROUP}" \
    && useradd \
    -s "${DEFAULT_USER_SHELL}" \
    -g "${DEFAULT_USER_PRIMARY_GROUP}" \
    -G "${DEFAULT_USER_SECONDARY_GROUPS}" \
    -m "${DEFAULT_USER}"

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE SUDO
# ----------------------------------------------------------------------------------------------------------------------

RUN echo \
    # CONTENT \
    "%${DEFAULT_USER_PRIMARY_GROUP} ALL=(ALL) NOPASSWD: ALL" \
    # END \
    >"/etc/sudoers.d/${DEFAULT_USER_PRIMARY_GROUP}"

# ######################################################################################################################
# SETUP: CUSTOM (AS DEV USER)
# ######################################################################################################################

USER "${DEFAULT_USER}"

#
# ENV
#

ENV HOME="/home/${DEFAULT_USER}"
ENV LANG="${DEFAULT_LANG}"
ENV LANGUAGE="${DEFAULT_LANG}"
ENV LC_ALL="${DEFAULT_LANG}"
ENV PATH="${HOME}/.local/bin:${PATH}"
ENV PROMPT_COMMAND="history -a"
ENV HISTFILE="${HOME}/.history/.bash_history"

#
# GENERAL
#

RUN mkdir -p "${HOME}/.config" \
    && mkdir "${HOME}/.history" \
    && touch "${HOME}/.history/.bash_history"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL TOOLS
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_CHECKOV="2.4.18"

#
# PYTHON
#

RUN pipx install "checkov==${VERSION_CHECKOV}"

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE DIRENV
# ----------------------------------------------------------------------------------------------------------------------

RUN echo "eval \"\$(direnv hook bash)\"" >> "${HOME}/.bashrc"

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE SHELL PROMPT
# ----------------------------------------------------------------------------------------------------------------------

RUN echo "eval \"\$(starship init bash)\"" >> "${HOME}/.bashrc"

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE ALIASES
# ----------------------------------------------------------------------------------------------------------------------

RUN echo "alias ls=\"lsd\"" >> "${HOME}/.bashrc"

# ######################################################################################################################
# RUN
# ######################################################################################################################

#
# Empty
#

# ----------------------------------------------------------------------------------------------------------------------
# HEALTHCHECK
# ----------------------------------------------------------------------------------------------------------------------

HEALTHCHECK NONE

# ----------------------------------------------------------------------------------------------------------------------
# ENTRYPOINT
# ----------------------------------------------------------------------------------------------------------------------

ENTRYPOINT [ ]

# ----------------------------------------------------------------------------------------------------------------------
# COMMAND
# ----------------------------------------------------------------------------------------------------------------------

CMD [ ]
