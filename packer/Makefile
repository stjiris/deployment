.PHONY: init fmt build validate-packer validate-cloudinit validate

CONFIG_FILE:=./config.pkr.hcl
VARIABLES_FILE:=./variables.pkrvars.hcl
TEMPLATE_FILE:=./ubuntu-jammy-server-cloudimg-amd64-docker.pkr.hcl

init:
	packer init ${CONFIG_FILE}

fmt:
	packer fmt ${TEMPLATE_FILE}

build:
	PACKER_LOG=1 packer build -force -var-file=${VARIABLES_FILE} ${TEMPLATE_FILE}

validate-packer:
	packer validate -var-file=${VARIABLES_FILE} ${TEMPLATE_FILE}

validate-cloudinit:
	cloud-init schema -c http/user-data

validate: validate-packer

all: init validate build