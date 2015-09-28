# Openstack Get Starting Installation

[![Join the chat at https://gitter.im/Orange-OpenSource/opnfv](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Orange-OpenSource/opnfv?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Openstack installation and configuration by Orange Labs.

## Introduction
This repo contains the tools and the scripts to install a full Openstack Juno over Ubuntu 14.04.

It aims to propose an **High Availability** deployment with **Bare Metal** provisioning.

The configuration is automatically done with **Puppet**, **Python scripts** and **Foreman**.

To keep the module dependencies up to date (and to download modules automatically), we use **r10k**.

The storage is handled by **Ceph**.

The only thing you should do is to provide a valid **YAML** configuration file.

### Puppet modules

We use pure **Puppet modules from OpenStack**:

 https://wiki.openstack.org/wiki/Puppet#Puppet_Modules

We also use an **OpenSteak Puppet module** to superseed the OpenStack modules:

 https://github.com/Orange-OpenSource/opnfv-puppet

All dependencies between puppet modules are managed by **r10k**:

 https://github.com/Orange-OpenSource/opnfv-r10k


## Installation

see [INSTALL](INSTALL.md)

## Architecture
### Basic setup

In a lab configuration, to optimize resource usage:

* All nodes are *compute* and *storage*: they all contains nova-compute, neutron-compute and ceph OSD
* 2 nodes are also *controllers* containing KVM VMs for Openstack bricks, a DNS node and HAproxy
* 1 node is a network gateway to external networks

![Image of Bridging topology - Controller and compute](https://github.com/Orange-OpenSource/opnfv/raw/master/docs/bridge_topology_controller_compute.jpg)

![Image of Bridging topology - Network](https://github.com/Orange-OpenSource/opnfv/raw/master/docs/bridge_topology_network.jpg)

On each server, we have at least 4 networks:

* **br-int** : Integration bridge. Tag/untag VLAN for VM. veth for VM will be in this bridge.
* **br-vm** : Distributed bridge between compute nodes. Used to transport VM flows. In our case, we use the physical interface name **em5** as support for this bridge.
* **br-adm** : Administration bridge. This is used by controller part of OpenStack (which are in KVM) and other administrative tasks. In our case, we use the physical interface named **em3** as support for this bridge. This network needs an internet access through a default gateway to proceed installation.
* **br-storage**: Storage bridge, used by the ceph cluster. In our case, we use the physical interface name **em4** as support for this bridge.

The network server will also have one other bridge:

* **br-ex** : Bridge to communicate with external networks. In our case, we use the physical interface named **em2** as support for this bridge.


![Image of Basic setup](https://github.com/Orange-OpenSource/opnfv/raw/master/docs/archi_reseau.png)


### How do we handle OpenStack functions
Each controller part of Openstack is created separatly in a KVM machine. So that it can easily be updated or redeployed.

Each KVM machine is automatically created by a script (opensteak-create-vm) and basic configuration comes through cloud-init. Openstack related configuration is handled by puppet.

### How do we provide HA
The work is still in progress, but we plan to use HAProxy in front of nodes, with VRRP IPs and weighted routes.

![Image of HA](https://raw.githubusercontent.com/Orange-OpenSource/opnfv/master/docs/opensteak_ha.png)

## Status
* Puppet modules:
 * Mysql: OK,
 * Rabbit: OK,
 * Keystone: OK,
 * Glance: OK,
   * with ceph: OK,
 * Cinder: OK,
   * with ceph: OK,
 * Nova: OK,
   * with ceph: OK,
 * Neutron: OK,
* Bare metal provisioning: OK with Foreman
* OpenDayLight: WiP
* High Availability: WiP

