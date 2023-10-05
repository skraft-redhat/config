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

# Updates a local clone of redhat-appstudio/infra-deployments to use the RHTAP
# configs defined in this repo.
# Usage:
#   update-infra-deployments.sh <PATH_TO_INFRA_DEPLOYMENTS>

set -o errexit
set -o pipefail
set -o nounset

# Ensure the expected output file exists.
OUTPUT="${1}/components/enterprise-contract/ecp.yaml"
if [[ ! -f "${OUTPUT}" ]]; then
    echo "Expected output file not found, ${OUTPUT}"
    exit 1
fi

# Resolve the acceptable bundles image to a digest.
acceptable_bundles='quay.io/redhat-appstudio-tekton-catalog/data-acceptable-bundles:latest'
echo "Pinning ${acceptable_bundles}..."
digest="$(skopeo manifest-digest <(skopeo inspect "docker://${acceptable_bundles}" --raw))"
acceptable_bundles_data="oci::${acceptable_bundles}@${digest}"
echo $acceptable_bundles_data

# Resolve the data files from the rhtap-ec-policy repo to a commit ID.
rhtap_data_gh_repo='release-engineering/rhtap-ec-policy'
echo "Pinning GitHub repo ${rhtap_data_gh_repo}..."
head_commit="$(
    gh api "/repos/${rhtap_data_gh_repo}/git/matching-refs/heads/main" --jq '.[0].object.sha'
)"
rhtap_data="github.com/${rhtap_data_gh_repo}//data?ref=${head_commit}"
echo $rhtap_data

# Make it easier to load the policy configs.
cd "$(git rev-parse --show-toplevel)"

# Something else is reponsible for maintaining the policy URL refs. Here we save their current value
# so we can ensure they stay the same. As a sanity check, we ensure that a single policy URL is used
# across all policies for the sake of simplicity given that is the current state.
policy_url="$(< "${OUTPUT}" yq '.spec.sources[].policy[]' | grep -v -- '---' | sort -u)"
if [[ "$(echo $policy_url | wc -w)" -ne "1" ]]; then
    echo -e "Unexpected amount of policy URLs: \n${policy_url}"
    exit 1
fi
echo $policy_url

# Always generate the output file from scratch and add some helper text on the generated file.
echo '#
# The contents of this file are automatically generated based on the RHTAP configs defined in the
# github.com/enterprise-contract/config repo. Any manual modifications will be overridden.
#
' > "${OUTPUT}"

# Figure out which policy config files to use.
policy_configs="$(
    < src/data.json \
    jq -r 'to_entries| .[] | select(.value.environment == "rhtap") | select(.value.deprecated | not) | "\(.key)/policy.yaml"' \
    | sort)"

for policy_config in $policy_configs; do
    name="$(dirname $policy_config)"
    # For legacy reasons, the everything config is called "all" in RHTAP
    if [[ "${name}" == 'everything' ]]; then
        name='all'
    fi

    echo "---" >> "${OUTPUT}"
    name="${name}" data0="${rhtap_data}" data1="${acceptable_bundles_data}" policy="${policy_url}" \
    yq -P -o yaml '{
        "apiVersion": "appstudio.redhat.com/v1alpha1",
        "kind": "EnterpriseContractPolicy",
        "metadata": {
            "name": strenv(name),
            "namespace": "enterprise-contract-service"
        },
        "spec": . }
        | .spec.sources[].data = [strenv(data0), strenv(data1)]
        | .spec.sources[].policy = [strenv(policy)]
        | sort_keys(..) ' \
        "${policy_config}"  >> "${OUTPUT}"
done

echo 'infra-deployments updated successfully'
