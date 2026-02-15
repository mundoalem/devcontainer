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

FROM ubuntu:24.04

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
ARG DEFAULT_USER_SECONDARY_GROUPS="sudo"
ARG DEFAULT_USER_SHELL="/bin/bash"
ARG DEFAULT_USER="dev"

# ----------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# ----------------------------------------------------------------------------------------------------------------------

#
# OS
#

ENV VERSION_UBUNTU="24.04"
ENV VERSION_UBUNTU_NAME="noble"

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
LABEL org.opencontainers.image.base.digest="985be7c735afdf6f18aaa122c23f87d989c30bba4e9aa24c8278912aac339a8d"
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

WORKDIR /

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL SYSTEM PACKAGES
# ----------------------------------------------------------------------------------------------------------------------

RUN export DEBIAN_FRONTEND="noninteractive" \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    direnv \
    gdb \
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
    tzdata \
    unzip \
    vim \
    wget \
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
# INSTALL HADOLINT
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_HADOLINT="2.14.0"
ENV URL_HADOLINT="https://github.com/hadolint/hadolint/releases/download/v${VERSION_HADOLINT}/hadolint-Linux-${TARGETARCH}"

#
# INSTALL
#

RUN curl -sSL -o /usr/local/bin/hadolint "${URL_HADOLINT}" \
    && chmod +x /usr/local/bin/hadolint

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL STARSHIP
# ----------------------------------------------------------------------------------------------------------------------

RUN curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL TENV
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_TENV="4.9.3"
ENV URL_TENV="https://github.com/tofuutils/tenv/releases/download/v${VERSION_TENV}/tenv_v${VERSION_TENV}_${TARGETARCH}.deb"

#
# INSTALL
#

RUN curl -fsSL -o /tmp/tenv.deb "${URL_TENV}" \
    && dpkg -i /tmp/tenv.deb \
    && rm -f /tmp/tenv.deb

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

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL ALEJANDRA
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_ALEJANDRA=4.0.0

#
# INSTALL
#

RUN export cpuarch=$(arch | sed s/arm64/aarch64/) \
    && curl -fsSL -o /usr/local/bin/alejandra "https://github.com/kamadorueda/alejandra/releases/download/${VERSION_ALEJANDRA}/alejandra-${cpuarch}-unknown-linux-musl" \
    && chmod +x /usr/local/bin/alejandra

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL TASK
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_TASK=3.45.4

#
# INSTALL
#

RUN curl -fsSL "https://github.com/go-task/task/releases/download/v${VERSION_TASK}/task_linux_${TARGETARCH}.tar.gz" | tar zxf - task \
    && mv task /usr/local/bin/task \
    && chmod +x /usr/local/bin/task

# ######################################################################################################################
# SETUP: CUSTOM (AS DEV USER)
# ######################################################################################################################

USER "${DEFAULT_USER}"

WORKDIR "/home/${DEFAULT_USER}"

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
# INSTALL NVM
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV VERSION_NVM="0.40.3"
ENV URL_NVM="https://raw.githubusercontent.com/nvm-sh/nvm/v${VERSION_NVM}/install.sh"

#
# INSTALL
#

RUN curl -o- "${URL_NVM}" | bash

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

ENV VERSION_CHECKOV="3.2.484"

#
# PYTHON
#

RUN pipx install "checkov==${VERSION_CHECKOV}"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL UV
# ----------------------------------------------------------------------------------------------------------------------

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

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
