#!/bin/bash

openstack overcloud deploy \
--timeout 100 \
--templates /usr/share/openstack-tripleo-heat-templates \
--stack overcloud \
--libvirt-type kvm \
--ntp-server clock1.rdu2.redhat.com \
-e /home/stack/virt_4nics/config_lvm.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e /home/stack/virt_4nics/network/network-environment.yaml \
-e /home/stack/virt_4nics/inject-trust-anchor.yaml \
-e /home/stack/virt_4nics/hostnames.yml \
-e /home/stack/virt_4nics/debug.yaml \
-e /home/stack/virt_4nics/nodes_data.yaml \
-e ~/containers-prepare-parameter.yaml \
-e /home/stack/firstboot.yaml \
--log-file overcloud_deployment_90.log
