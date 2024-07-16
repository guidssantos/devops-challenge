#!/bin/bash

instance_ip=$(terraform output -raw IP)

cat <<EOL > inventory.ini
[server]
ec2-instance ansible_host="$instance_ip" ansible_user=ubuntu  ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOL
