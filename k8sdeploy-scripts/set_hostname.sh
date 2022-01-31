#!/usr/bin/env bash

set -e

CMD=`more k8sdeploy-scripts/hosts.pub|awk '{print $1}'`

for i in $CMD
do
cat ./k8sdeploy-scripts/hosts.local |ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ssh-keys/id_rsa_aws centos@$i -T "sudo bash -c 'cat >> /etc/hosts'"
cat ./k8sdeploy-scripts/authorized_keys |ssh  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ssh-keys/id_rsa_aws centos@$i -T "cat >> ~/.ssh/authorized_keys"
done

