#!/usr/bin/env bash

/usr/bin/kubectl label node $HOSTNAME node-role.kubernetes.io/worker=worker
