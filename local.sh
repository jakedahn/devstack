#!/usr/bin/env bash

TOP_DIR=$(cd $(dirname "$0") && pwd)
source $TOP_DIR/functions
source $TOP_DIR/stackrc
DEST=${DEST:-/opt/stack}
FILES=$TOP_DIR/files

## Create project and user
keystone bootstrap --user-name jakedahn --pass hockey --tenant-name jakedahn --role-name jake

## Add first keypair found in localhost:$HOME/.ssh
nova --os-username=jakedahn --os-password=hockey --os-tenant-name=jakedahn keypair-add --pub_key=/home/jakedahn/.ssh/id_rsa.pub jakedahn

# delete lame flavors
nova flavor-delete heat
nova flavor-delete micro
nova flavor-delete nano

source $TOP_DIR/userrc
nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0
nova secgroup-add-rule default udp 1 65535 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

# Glance connection info.  Note the port must be specified.
GLANCE_HOSTPORT=192.168.23.1:9292
GLANCE_SERVICE_PROTOCOL=http

source $TOP_DIR/adminrc
TOKEN=$(keystone token-get | grep ' id ' | get_field 2)
upload_image "https://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img" $TOKEN
