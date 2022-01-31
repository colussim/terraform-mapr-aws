#!/usr/bin/env bash

set -e

eval "$(jq -r '@sh "HOST=\(.host)"')"

# Fetch the join command
CMD=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    centos@$HOST -i /Users/manu/Documents/App/Terraform/terraform-mapr-aws/ssh-keys/id_rsa_aws kubeadm token create --print-join-command)

# Produce a JSON object containing the join command
jq -n --arg command "$CMD" '{"command":$command}'
