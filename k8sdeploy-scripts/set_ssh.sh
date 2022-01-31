#!/usr/bin/env bash

set -e

ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ssh-keys/id_rsa_aws centos@$1 "cat ~/.ssh/id_rsa_$2.pub" >> k8sdeploy-scripts/authorized_keys

