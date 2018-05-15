#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo 'OPTIONS="$${OPTIONS} --storage-opt dm.basesize=${docker_storage_size}G"' >> /etc/sysconfig/docker
/etc/init.d/docker restart
echo ECS_ENGINE_AUTH_TYPE=dockercfg >> /etc/ecs/ecs.config
echo 'ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/": { "auth": "${dockerhub_token}", "email": "${dockerhub_email}"}}' >> /etc/ecs/ecs.config

# mount the extra EBS volume
while [ ! -e /dev/xvdb ] ; do sleep 1 ; done

if [ "$(file -b -s /dev/xvdb)" == "data" ]; then
  mkfs -t ext4 /dev/xvdb
fi

mkdir /data
mount /dev/xvdb /data

echo "/dev/xvdb /data ext4 defaults 0 0" >> /etc/fstab

# Append addition user-data script
${additional_user_data_script}
