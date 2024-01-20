#!/usr/bin/env bats

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
# TESTS
# ######################################################################################################################

# ----------------------------------------------------------------------------------------------------------------------
# DOCKER
# ----------------------------------------------------------------------------------------------------------------------

@test "docker compose plugin is available" {
    run docker compose version
    [ "$status" -eq 0 ]
}

@test "docker buildx plugin is available" {
    run docker buildx version
    [ "$status" -eq 0 ]
}

# ----------------------------------------------------------------------------------------------------------------------
# USER
# ----------------------------------------------------------------------------------------------------------------------

@test "dev user is created" {
    run bash -c "grep -E '^dev:x:' /etc/passwd"
    [ "$status" -eq 0 ]
}

@test "developers is the primary group of dev user" {
    run bash -c "id dev | grep -E 'gid=[0-9]+\(developers\)'"
    [ "$status" -eq 0 ]
}

@test "sudo is a secondary group of dev user" {
    run bash -c "id dev | grep -E 'groups=.*[0-9]+\(sudo\)'"
    [ "$status" -eq 0 ]
}

@test "docker is a secondary group of dev user" {
    run bash -c "id dev | grep -E 'groups=.*[0-9]+\(docker\)'"
    [ "$status" -eq 0 ]
}

# ----------------------------------------------------------------------------------------------------------------------
# SYSTEM CONFIGURATION
# ----------------------------------------------------------------------------------------------------------------------

@test "sudo is configured" {
    run ls /etc/sudoers.d/developers
    [ "$status" -eq 0 ]
}

# ----------------------------------------------------------------------------------------------------------------------
# PACKAGES
# ----------------------------------------------------------------------------------------------------------------------

@test "ansible is installed" {
    run which ansible
    [ "$status" -eq 0 ]
}

@test "checkov is installed" {
    run which checkov
    [ "$status" -eq 0 ]
}

@test "curl is installed" {
    run which curl
    [ "$status" -eq 0 ]
}

@test "delta is installed" {
    run which delta
    [ "$status" -eq 0 ]
}

@test "direnv is installed" {
    run which direnv
    [ "$status" -eq 0 ]
}

@test "git is installed" {
    run which git
    [ "$status" -eq 0 ]
}

@test "goenv is installed" {
    run which goenv
    [ "$status" -eq 0 ]
}

@test "gpg is installed" {
    run which gpg
    [ "$status" -eq 0 ]
}

@test "hadolint is installed" {
    run which hadolint
    [ "$status" -eq 0 ]
}

@test "lsd is installed" {
    run which lsd
    [ "$status" -eq 0 ]
}

@test "make is installed" {
    run which git
    [ "$status" -eq 0 ]
}

@test "pyenv is installed" {
    run which pyenv
    [ "$status" -eq 0 ]
}

@test "sudo is installed" {
    run which sudo
    [ "$status" -eq 0 ]
}

@test "tfenv is installed" {
    run which tfenv
    [ "$status" -eq 0 ]
}

@test "unzip is installed" {
    run which unzip
    [ "$status" -eq 0 ]
}
