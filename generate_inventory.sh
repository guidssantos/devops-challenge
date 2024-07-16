#!/bin/bash

instance_ip=$(terraform output -raw IP)

cat <<EOL > ansible/inventory.ini
[server]
$instance_ip
EOL
