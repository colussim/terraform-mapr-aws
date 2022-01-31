#!/usr/bin/env bash

set -e

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ssh-keys/id_rsa_aws centos@$1:~/.kube/config admin.conf
