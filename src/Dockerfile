# ######################################################################################################################
# LICENSE
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
# PRELUDE
# ######################################################################################################################

#
# Empty
#

# ######################################################################################################################
# BASE IMAGE
# ######################################################################################################################

FROM ubuntu:22.04

# ######################################################################################################################
# ARGUMENTS
# ######################################################################################################################

#
# DOCKER BUILDKIT'S ARGUMENTS
#

ARG BUILDARCH
ARG BUILDOS
ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG TARGETPLATFORM

#
# PROJECT'S ARGUMENTS
#

ARG PROJECT_BUILD_DATE
ARG PROJECT_COMMIT
ARG PROJECT_VERSION

#
# IMAGE ARGUMENTS
#

ARG DEFAULT_LANG="C.UTF-8"
ARG DEFAULT_USER_PRIMARY_GROUP="developers"
ARG DEFAULT_USER_SECONDARY_GROUPS="sudo,docker"
ARG DEFAULT_USER_SHELL="/bin/bash"
ARG DEFAULT_USER="mundoalem"

# ######################################################################################################################
# LABELS
# ######################################################################################################################

#
# REFERENCE
#
#   - https://github.com/opencontainers/image-spec/blob/main/annotations.md
#

LABEL org.opencontainers.artifact.created="${PROJECT_BUILD_DATE}"
LABEL org.opencontainers.artifact.description="Base container image for development"
LABEL org.opencontainers.image.authors="Egon Braun <egon@mundoalem.io>"
LABEL org.opencontainers.image.base.digest="27cb6e6ccef575a4698b66f5de06c7ecd61589132d5a91d098f7f3f9285415a9"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:22.04"
LABEL org.opencontainers.image.created="${PROJECT_BUILD_DATE}"
LABEL org.opencontainers.image.description="Base container image for development"
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

#
# INSTALL SYSTEM PACKAGES
#

RUN export DEBIAN_FRONTEND="noninteractive" \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    direnv \
    git \
    git-extras \
    gnupg \
    gpg-agent \
    locales \
    lsb-release \
    make \
    pkg-config \
    python3 \
    python3-pip \
    software-properties-common \
    ssh \
    sudo \
    unzip \
    && apt-get autoremove -y \
    && apt-get clean autoclean -y \
    && rm -r /var/cache/* /var/lib/apt/lists/*

#
# CONFIGURE LOCALISATION
#

RUN locale-gen "${DEFAULT_LANG}" \
    && update-locale LANG="${DEFAULT_LANG}"

# ######################################################################################################################
# SETUP: TOOLS
# ######################################################################################################################

#
# INSTALL: DOCKER
#

RUN curl -sSL --http1.1 -o /tmp/docker-ce-cli.deb "https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/${TARGETARCH}/docker-ce-cli_20.10.21~3-0~ubuntu-jammy_${TARGETARCH}.deb" \
    && dpkg -i /tmp/docker-ce-cli.deb \
    && curl -sSL --http1.1 -o /tmp/docker-compose-plugin.deb "https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/${TARGETARCH}/docker-compose-plugin_2.12.2~ubuntu-jammy_${TARGETARCH}.deb" \
    && dpkg -i /tmp/docker-compose-plugin.deb \
    && rm -f /tmp/docker-ce-cli.deb \
    && rm -f /tmp/docker-compose-plugin.deb \
    && groupadd docker

#
# INSTALL HADOLINT
#

RUN curl -o /usr/local/bin/hadolint -sSL "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-${TARGETARCH}" \
    && chmod 0755 /usr/local/bin/hadolint

#
# INSTALL GIT DELTA
#

RUN curl -sSL --http1.1 -o /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/0.15.1/git-delta_0.15.1_${TARGETARCH}.deb" \
    && dpkg -i /tmp/git-delta.deb \
    && rm -f /tmp/git-delta.deb

#
# INSTALL CONTAINER-STRUCTURE-TEST
#

RUN curl -sSL --http1.1 -o /usr/local/bin/container-structure-test "https://storage.googleapis.com/container-structure-test/v1.14.0/container-structure-test-linux-${TARGETARCH}" \
    && chmod +x /usr/local/bin/container-structure-test

# ######################################################################################################################
# SETUP: LOCAL USER
# ######################################################################################################################

#
# CREATE USER
#

RUN groupadd "${DEFAULT_USER_PRIMARY_GROUP}" \
    && useradd \
    -s "${DEFAULT_USER_SHELL}" \
    -g "${DEFAULT_USER_PRIMARY_GROUP}" \
    -G "${DEFAULT_USER_SECONDARY_GROUPS}" \
    -m "${DEFAULT_USER}"

#
# CONFIGURE SUDO
#

RUN echo "%${DEFAULT_USER_PRIMARY_GROUP} ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/${DEFAULT_USER_PRIMARY_GROUP}"

# ######################################################################################################################
# USER
# ######################################################################################################################

USER "${DEFAULT_USER}"

#
# ENVIRONMENT VARIABLES
#

ENV HOME="/home/${DEFAULT_USER}"
ENV LANG="${DEFAULT_LANG}"
ENV LANGUAGE="${DEFAULT_LANG}"
ENV LC_ALL="${DEFAULT_LANG}"
ENV PATH="${HOME}/.local/bin:${PATH}"

#
# CONFIGURE HISTORY
#

RUN mkdir "${HOME}/.history" \
    && touch "${HOME}/.history/.bash_history" \
    && chown -R "${DEFAULT_USER}:${DEFAULT_GROUP}" "${HOME}/.history" \
    && echo "export PROMPT_COMMAND='history -a'" >> "${HOME}/.bashrc" \
    && echo "export HISTFILE=$HOME/.history/.bash_history" >> "${HOME}/.bashrc"

#
# CONFIGURE DIRENV
#

RUN echo "eval \"\$(direnv hook bash)\"" >> $HOME/.bashrc \
    && echo "direnv allow /workspaces/*" >> $HOME/.bashrc

# ######################################################################################################################
# SETUP: USER TOOLS
# ######################################################################################################################

#
# INSTALL PYTHON TOOLS
#

RUN pip3 install --no-cache-dir "checkov==2.2.201"

# ######################################################################################################################
# COMMAND / ENTRYPOINT
# ######################################################################################################################

#
# HEALTHCHECK
#

HEALTHCHECK NONE

#
# START COMMAND
#

CMD ["/bin/bash"]
