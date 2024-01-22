# ######################################################################################################################
# LICENSE
# ######################################################################################################################

#
# This file is part of devcontainer.
#
# The devcontainer is free software: you can redistribute it and/or modify it under the terms of the GNU Affero
# General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# The devcontainer is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with devcontainer. If not, see
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
LABEL org.opencontainers.artifact.description="Container image to be used as a remote development environment in Visual Studio Code"
LABEL org.opencontainers.image.authors="Egon Braun <egon@mundoalem.io>"
LABEL org.opencontainers.image.base.digest="4783be26912a96818aa1c9468ea8acb5eff2608697f62deff67048595a613145"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:${VERSION_UBUNTU}"
LABEL org.opencontainers.image.created="${PROJECT_BUILD_DATE}"
LABEL org.opencontainers.image.description="Container image to be used as a remote development environment in Visual Studio Code"
LABEL org.opencontainers.image.documentation="https://hub.docker.com/r/mundoalemio/devcontainer"
LABEL org.opencontainers.image.licenses="AGPLv3"
LABEL org.opencontainers.image.revision="${PROJECT_COMMIT}"
LABEL org.opencontainers.image.source="https://github.com/mundoalem/devcontainer"
LABEL org.opencontainers.image.title="dev-base"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/mundoalemio/devcontainer"
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
    binutils-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu-dbg \
    build-essential \
    ca-certificates \
    curl \
    direnv \
    gcc-aarch64-linux-gnu \
    git \
    git-extras \
    gnupg2 \
    gpg-agent \
    jq \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxmlsec1-dev \
    locales \
    lsb-release \
    lsd \
    make \
    pipx \
    pkg-config \
    python3 \
    python3-full \
    software-properties-common \
    ssh \
    sudo \
    tk-dev \
    unzip \
    vim \
    xz-utils \
    zlib1g-dev \
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

ENV VERSION_DOCKER_CLI="25.0.0-1"
ENV VERSION_DOCKER_BUILDX_PLUGIN="0.12.1-1"
ENV VERSION_DOCKER_COMPOSE_PLUGIN="2.24.1-1"
ENV FILENAME_DOCKER_SUFFIX="ubuntu.${VERSION_UBUNTU}~${VERSION_UBUNTU_NAME}_${TARGETARCH}.deb"
ENV FILENAME_DOCKER_CLI="docker-ce-cli_${VERSION_DOCKER_CLI}~${FILENAME_DOCKER_SUFFIX}"
ENV FILENAME_DOCKER_BUILDX_PLUGIN="docker-buildx-plugin_${VERSION_DOCKER_BUILDX_PLUGIN}~${FILENAME_DOCKER_SUFFIX}"
ENV FILENAME_DOCKER_COMPOSE_PLUGIN="docker-compose-plugin_${VERSION_DOCKER_COMPOSE_PLUGIN}~${FILENAME_DOCKER_SUFFIX}"
ENV URL_DOCKER_BASE="https://download.docker.com/linux/ubuntu/dists/${VERSION_UBUNTU_NAME}/pool/stable/${TARGETARCH}"
ENV URL_DOCKER_CLI="${URL_DOCKER_BASE}/${FILENAME_DOCKER_CLI}"
ENV URL_DOCKER_BUILDX_PLUGIN="${URL_DOCKER_BASE}/${FILENAME_DOCKER_BUILDX_PLUGIN}"
ENV URL_DOCKER_COMPOSE_PLUGIN="${URL_DOCKER_BASE}/${FILENAME_DOCKER_COMPOSE_PLUGIN}"

#
# INSTALL
#

RUN curl -sSL -o "/tmp/${FILENAME_DOCKER_CLI}" "${URL_DOCKER_CLI}" \
    && curl -sSL -o "/tmp/${FILENAME_DOCKER_BUILDX_PLUGIN}" "${URL_DOCKER_BUILDX_PLUGIN}" \
    && curl -sSL -o "/tmp/${FILENAME_DOCKER_COMPOSE_PLUGIN}" "${URL_DOCKER_COMPOSE_PLUGIN}" \
    && dpkg -i "/tmp/${FILENAME_DOCKER_CLI}" \
    && dpkg -i "/tmp/${FILENAME_DOCKER_BUILDX_PLUGIN}" \
    && dpkg -i "/tmp/${FILENAME_DOCKER_COMPOSE_PLUGIN}" \
    && groupadd docker \
    && rm -f "/tmp/"*"${FILENAME_DOCKER_SUFFIX}"

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
    && touch "${HOME}/.history/.bash_history" \
    && mkdir -p "${HOME}/.local/bin"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL GOENV
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV GOENV_ROOT="${HOME}/.goenv"
ENV PATH="${GOENV_ROOT}/bin:${PATH}"

#
# INSTALL
#

RUN git clone https://github.com/go-nv/goenv.git "${HOME}/.goenv" \
    && echo "eval \"\$(goenv init -)\"" >> "${HOME}/.bashrc" \
    && echo "export PATH=\"\$GOPATH/bin:\$GOROOT/bin:\$PATH\"" >> "${HOME}/.bashrc"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL PYENV
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/bin:$PATH"

#
# INSTALL
#

RUN curl -fsSL https://pyenv.run | bash \
    && echo "eval \"\$(pyenv init --path)\"" >> "${HOME}/.bashrc" \
    && echo "eval \"\$(pyenv virtualenv-init -)\"" >> "${HOME}/.bashrc"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL TOOLS
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_CHECKOV="3.1.67"

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
