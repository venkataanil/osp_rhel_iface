# osp_rhel_iface
1) os-net-config-mappings.yaml creates /etc/os-net-config/mapping.yaml with below contents
[heat-admin@controller-0 ~]$ cat /etc/os-net-config/mapping.yaml 
interface_mapping:
  eno1: eth0
  eno2: eth1
  enp94s0f0: eth2
  enp94s0f1: eth3
  enp94s0f2: eth4
  enp94s0f3: eth5

2) network_config_hook in controller.yaml and compute.yaml nic-configs,
will replace real interface in nic_mapping in the /etc/os-net-config/config.json i.e
"nic_mapping": {"enp94s0f0": "enp94s0f0"} will be converted to
"nic_mapping": {"enp94s0f0": "eth2"}
 
[heat-admin@compute-0 ~]$ cat /etc/os-net-config/config.json
{"network_config": [{"addresses": [{"ip_netmask": "192.168.24.100/24"}], "name": "enp94s0f1", "routes": [{"ip_netmask": "169.254.169.254/32", "next_hop": "192.168.24.1"}], "type": "interface", "nic_mapping": {"enp94s0f1": "enp94s0f1"}, "use_dhcp": false}, {"members": [{"name": "enp94s0f0", "nic_mapping": {"enp94s0f0": "enp94s0f0"}, "primary": true, "type": "interface"}, {"addresses": [{"ip_netmask": "172.17.1.103/24"}], "type": "vlan", "vlan_id": 301}, {"addresses": [{"ip_netmask": "172.17.3.29/24"}], "type": "vlan", "vlan_id": 302}], "name": "br-isolated", "type": "ovs_bridge", "use_dhcp": false}, {"members": [{"name": "enp94s0f3", "nic_mapping": {"enp94s0f3": "enp94s0f3"}, "primary": true, "type": "interface"}, {"addresses": [{"ip_netmask": "172.17.2.147/24"}], "type": "vlan", "vlan_id": 304}], "name": "br-tenant", "type": "ovs_bridge", "use_dhcp": false}]}

After running the network_config_hook

[heat-admin@compute-0 ~]$ python mypy.py 
[heat-admin@compute-0 ~]$ cat /etc/os-net-config/config.json 
{"network_config": [{"addresses": [{"ip_netmask": "192.168.24.14/24"}], "name": "enp94s0f1", "nic_mapping": {"enp94s0f1": "eth3"}, "routes": [{"ip_netmask": "169.254.169.254/32", "next_hop": "192.168.24.1"}], "type": "interface", "use_dhcp": false}, {"members": [{"name": "enp94s0f0", "nic_mapping": {"enp94s0f0": "eth2"}, "type": "interface"}, {"addresses": [{"ip_netmask": "172.17.1.46/24"}], "type": "vlan", "vlan_id": 301}, {"addresses": [{"ip_netmask": "172.17.3.123/24"}], "type": "vlan", "vlan_id": 302}], "name": "br-isolated", "type": "ovs_bridge", "use_dhcp": false}, {"members": [{"name": "enp94s0f3", "nic_mapping": {"enp94s0f3": "eth5"}, "type": "interface"}, {"addresses": [{"ip_netmask": "172.17.2.67/24"}], "type": "vlan", "vlan_id": 304}], "name": "br-tenant", "type": "ovs_bridge", "use_dhcp": false}]}[heat-admin@compute-0 ~]$ 

3) Need to run os-net-config command with "--persist-mapping" option like below
os-net-config -c config.json -d -v --detailed-exit-codes --noop -m mapping_org.yaml --persist-mapping --exit-on-validation-errors
So, needed to change that in run-os-net-config.sh 
