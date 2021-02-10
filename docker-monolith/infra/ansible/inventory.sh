#!/usr/bin/env bash
sed '2,$d' ./ansible/hosts > ./ansible/hosts.backup && mv ./ansible/hosts.backup ./ansible/hosts
yc compute instance list | grep [0-9] | awk '{print $10}' >> ./ansible/hosts
