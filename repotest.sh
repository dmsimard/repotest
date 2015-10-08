#!/bin/bash
#   Copyright Red Hat, Inc. All Rights Reserved.
#
#   Licensed under the Apache License, Version 2.0 (the "License"); you may
#   not use this file except in compliance with the License. You may obtain
#   a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#   License for the specific language governing permissions and limitations
#   under the License.
#
#   Author: David Moreau Simard <dms@redhat.com>
#   Credit: Ahmed Rahal for the Write Echo framework
#
#   Downloads a .repo file, sets it up and does some rough tests to try and see
#   if the repository seems to work.
#   Exits 1 if there's been a problem at some point, otherwise 0.
#   Usage: ./repotest.sh <http://url/repository.repo>

PATH=/usr/sbin:/usr/bin:/sbin:/bin
DEBUG=0
TMPDIR=$(mktemp -d /tmp/repotest.XXXXX)

function WriteInfo() {
    wi_DateTimeStamp=$(date +%d/%m/%Y-%H:%M:%S)
    echo "${wi_DateTimeStamp} INFO: ${1}"
    return 0
}

function WriteErr() {
    we_DateTimeStamp=$(date +%d/%m/%Y-%H:%M:%S)
    echo "${we_DateTimeStamp} ERROR: ${1}" >&2
    return 0
}

function WriteDebug() {
    [ ${DEBUG:-1} -eq 0 ] && return 0
    wd_DateTimeStamp=$(date +%d/%m/%Y-%H:%M:%S)
    echo "${wd_DateTimeStamp} DEBUG: ${1}"
    return 0
}

function ExitScript() {
    es_status="${1}"
    es_message="${2}"
    [ -z "${es_status}" ] && es_status=0
    [ -z "${es_message}" ] && es_message="exit status is '${es_status}'"
    [ ${es_status} -eq 0 ] && WriteInfo "${es_message}" || WriteErr "${es_message}";
    exit ${es_status}
}

function Usage() {
    echo "Usage: ${0} <http://url/repository.repo>"
    return 0
}

function DownloadRepo() {
    WriteInfo "Downloading repository file from ${REPO_URL} to ${REPO_PATH} ..."
    WriteDebug "${CURL} -s ${REPO_URL} |tee ${REPO_PATH}"
    ${CURL} -s ${REPO_URL} |tee ${REPO_PATH}
    echo ""

    # Checksum repository from baseurl with retrieve repository
    export baseurl=$(awk -F= '/baseurl/ {print $2}' "${REPO_PATH}")
    WriteInfo "Testing against baseurl '${baseurl}'."

    WriteDebug "${CURL} -so /tmp/${REPO_FILENAME} ${baseurl}/${REPO_FILENAME}"
    ${CURL} -so ${TMP_REPO_PATH} ${baseurl}/${REPO_FILENAME}

    WriteDebug "diff -q --side-by-side --suppress-common-lines ${TMP_REPO_PATH} ${REPO_PATH}"
    if diff -q --side-by-side --suppress-common-lines "${TMP_REPO_PATH}" "${REPO_PATH}"; then
        WriteInfo "Retrieved repository and baseurl checksum successfully."
    else
        ExitScript 1 "Retrieved repository and it's baseurl do not checksum (race condition?), aborting."
    fi
}

DumpRepoConfig() {
    WriteInfo "Dumping repository configuration to in $(pwd)/repository.properties ..."
    # delorean repository format: /4b/15/4b155c41faaababb57c5b1b9e016402bb4376d07_292dd64b
    delorean_pin_version=$(echo $baseurl |awk -F/ '{print $(NF-2)"/"$(NF-1)"/"$(NF)}')
    echo "baseurl = ${baseurl}" >repository.properties
    echo "delorean_pin_version = ${delorean_pin_version}" >>repository.properties
}

function ValidateRepo() {
    WriteInfo "Validating that installed repositories work ..."
    [[ -s "${REPO_PATH}" ]] || ExitScript 1 "${REPO_PATH} doesn't exist or is empty."

    WriteInfo "Running ${YUM} clean all, makecache, repolist"
    ${YUM} clean all || ExitScript 1 "Could not run '${YUM} clean all' successfully."
    ${YUM} makecache || ExitScript 1 "Could not run '${YUM} makecache' successfully."
    ${YUM} repolist || ExitScript 1 "Could not run '${YUM} repolist' successfully."

    # Optimistic way of supporting N repositories in a .repo file
    for repository in $(egrep "\[.*\]" ${REPO_PATH} | sed -e 's/.*\[\([^]]*\)\].*/\1/g')
    do
        WriteInfo "Package list for ${repository}"
        ${YUM} --disablerepo="*" --enablerepo="${repository}" list available || ExitScript 1 "Could not retrieve list of available packages for ${repository}"
    done
}

function CleanupRepo() {
    WriteInfo "Cleaning up ..."
    [ ! -z "${TMP_REPO_PATH}" ] && rm -f ${TMP_REPO_PATH}
    [ ! -z "${REPO_PATH}" ] && rm -f ${REPO_PATH}
    [ ! -z "${TMPDIR}" ] && rm -rf ${TMPDIR}
    ${YUM} clean all
}
trap CleanupRepo EXIT

# Pre-flight, configuration and dependencies
[[ $EUID -ne 0 ]] && ExitScript 1 "This script must be run as root"
if [ -z "${1}" ]; then
    Usage
    ExitScript 1 "Please provide a repository URL."
fi

if [[ ! "${1}" =~ http.*\.repo ]]; then
    Usage
    ExitScript 1 "Please provide a valid repository URL."
fi

# Ensure curl is there
CURL=$(command -v curl) || true
if [ -z "${CURL}" ]; then
    WriteInfo "Installing curl ..."
    yum -y -q install curl
    CURL=$(command -v curl)
fi

# Default to dnf, otherwise choose yum
YUM=$(command -v dnf) || YUM=$(command -v yum)

# Repository constants
REPO_URL="${1}"
REPO_FILENAME=$(echo "${REPO_URL}" |awk -F/ '{print $(NF)}')
REPO_PATH="/etc/yum.repos.d/${REPO_FILENAME}"
TMP_REPO_PATH="${TMPDIR}/${REPO_FILENAME}"

# Fetch repository and try to load stuff from it
DownloadRepo
ValidateRepo
DumpRepoConfig

ExitScript 0 "Finished validating repositories."
