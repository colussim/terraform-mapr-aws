#!/usr/bin/env bash

set -e
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ssh-keys/id_rsa_aws admin.conf centos@$1:~/.kube/config
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ssh-keys/id_rsa_aws k8sconf/setrole.sh centos@$1:~/setrole.sh
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ssh-keys/id_rsa_aws centos@$1 "chmod 755 ~/setrole.sh;~/setrole.sh"
