.PHONY: download customize create

BASE_URL:="https://cloud-images.ubuntu.com/releases/jammy/release/"
IMG_NAME:="ubuntu-22.04-server-cloudimg-amd64.img"
KVM_NAME:="ubuntu-kvm64.img"

download:
	wget -c ${BASE_URL}${IMG_NAME}

customize:
    rsync --progress ${IMG_NAME} ${KVM_NAME}.tmp
	virt-customize -a ${KVM_NAME}.tmp --install qemu-guest-agent
	virt-customize -a ${KVM_NAME}.tmp --run-command "sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
	virt-customize -a ${KVM_NAME}.tmp --ssh-inject root
	mv ${KVM_NAME}.tmp ${KVM_NAME}

create:
	./create_ubuntu_kvm64.sh

all: download customize create