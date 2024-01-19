#!/usr/bin/env bash
# Copyright The Enterprise Contract Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

# Verify the policy source URLs are valid.
# Usage:
#   verify-policy-sources.sh

set -o errexit
set -o pipefail
set -o nounset

ERRORS=false

verify_url() {
    url=$1
    inspect_type=$2
    echo -e "\n🕵️‍♀️ $url..."

    set +e
    info="$(ec inspect "${inspect_type}" --source "${url}" --output=json)"
    inspect_status=$?
    set -e
    if [[ $inspect_status -ne 0 ]]; then
        echo '❌ Unable to inspect policy URL'
        ERRORS=true
        return
    else
        echo '✅ Policy URL inspection successful'
    fi

    set +e
    echo "${info}" | jq '.' > /dev/null
    jq_status=$?
    set -e
    if [[ $jq_status -ne 0 ]]; then
        echo '❌ Data from URL is not valid JSON'
        ERRORS=true
        return
    else
        echo '✅ Data from URL is valid JSON'
    fi
}

policy_configs="$(< src/data.json yq '. | keys | .[] + "/policy.yaml"' -r)"

policy_urls="$(yq eval '.sources[].policy[]' $policy_configs | grep -v -- '---' | sort -u)"
for url in $policy_urls; do
    verify_url "${url}" 'policy'
done

policy_data="$(yq eval '.sources[].data[]' $policy_configs | grep -v -- '---' | sort -u)"
for url in $policy_data; do
    verify_url "${url}" 'policy-data'
done

echo
if [ $ERRORS = true ]; then
    echo '😭 Errors were found'
    exit 1
fi

echo '😺 Success!'
