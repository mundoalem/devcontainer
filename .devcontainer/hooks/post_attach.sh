#!/bin/bash

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
# HOOK: POST START
# ######################################################################################################################

# ----------------------------------------------------------------------------------------------------------------------
# DIRENV
# ----------------------------------------------------------------------------------------------------------------------

direnv allow /workspaces/*

# ----------------------------------------------------------------------------------------------------------------------
# DOCKER
# ----------------------------------------------------------------------------------------------------------------------

sudo chown root:docker /var/run/docker.sock
sudo chmod g+w /var/run/docker.sock

# ----------------------------------------------------------------------------------------------------------------------
# GIT
# ----------------------------------------------------------------------------------------------------------------------

ls -d /workspaces/* | xargs git config --global --add safe.directory

# ----------------------------------------------------------------------------------------------------------------------
# STARSHIP
# ----------------------------------------------------------------------------------------------------------------------

starship preset plain-text-symbols -o ~/.config/starship.toml
starship config container.disabled true
