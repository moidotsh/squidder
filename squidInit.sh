#!/bin/bash
echo "Enter IP address:"
read ip
echo "Enter proxy password:"
read -s password
echo ""
echo "Generating ssh key pair"
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096
fi
echo "Copying public key to remote machine"
ssh-copy-id -i ~/.ssh/id_rsa.pub -f root@"$ip"
echo "Uploading remote script"
scp remote_script.sh root@"$ip":~/
echo "Uploading squid.conf to staging location"
scp squid.conf root@"$ip":~/squid.conf.custom
echo "Running remote script"
ssh root@"$ip" "bash ~/remote_script.sh '$password'"
