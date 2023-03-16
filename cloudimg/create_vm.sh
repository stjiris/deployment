#!/bin/sh

IMG_NAME="custom-ubuntu-22.04-server-cloudimg-amd64.img"
TEMPL_NAME="ubuntu-jammy-server-cloudimg-amd64"
VMID="9000"
MEM="2048"
DISK_SIZE="32G"
DISK_STOR="local"
NET_BRIDGE="vmbr0"
LOCAL_BRIDGE="vmbr1"
qm create $VMID --name $TEMPL_NAME --memory $MEM \
    --cores 2 --sockets 1 --cpu cputype=kvm64 --kvm 1 --numa 1 \
    --net0 virtio,bridge=$LOCAL_BRIDGE --net1 virtio,bridge=$NET_BRIDGE
qm set $VMID --args "-cpu kvm64,+cx16,+lahf_lm,+popcnt,+sse3,+ssse3,+sse4.1,+sse4.2"
qm importdisk $VMID $IMG_NAME $DISK_STOR
qm set $VMID --scsihw virtio-scsi-pci --virtio0 $DISK_STOR:$VMID/vm-$VMID-disk-0.raw
qm set $VMID --serial0 socket
qm set $VMID --ide2 $DISK_STOR:cloudinit
qm set $VMID --boot c --bootdisk virtio0

qm set $VMID --agent 1
qm set $VMID --hotplug disk,network,usb,memory,cpu
qm set $VMID --vcpus 1
qm set $VMID --vga qxl
qm set $VMID --ipconfig0 ip=dhcp
qm resize $VMID virtio0 $DISK_SIZE
qm template $VMID
