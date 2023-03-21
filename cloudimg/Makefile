.PHONY: download customize create

BASE_URL:="https://cloud-images.ubuntu.com/releases/jammy/release/"
IMG_NAME:="ubuntu-22.04-server-cloudimg-amd64.img"
KVM_NAME:="ubuntu-kvm64.img"

download:
	wget -c ${BASE_URL}${IMG_NAME}

customize:
	virt-customize -a ${IMG_NAME} --install qemu-guest-agent
	virt-customize -a ${IMG_NAME} --run-command "sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
	virt-customize -a ${IMG_NAME} --ssh-inject root
	mv ${IMG_NAME} ${KVM_NAME}

create:
	./create_ubuntu_kvm64.sh

all: download customize create