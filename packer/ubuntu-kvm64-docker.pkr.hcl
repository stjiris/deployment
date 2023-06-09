# Packer template to create a VM Image based on Ubuntu Server 22.04 with Docker on Proxmox

variable "proxmox_api_url" {
  type    = string
  default = "https://fqdn:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "packer@pam!packer"
}

variable "proxmox_api_token_secret" {
  type      = string
  default   = "api-token-secret"
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "node1"
}

variable "virtual_machine_id" {
  type    = number
  default = 8000
}

variable "clone_vm_id" {
  type    = number
  default = 9000
}

variable "ssh_keypair_name" {
  type    = string
  default = "id_rsa"
}

variable "ssh_private_key_file" {
  type    = string
  default = "/root/.ssh/id_rsa"
}

variable "ssh_username" {
  type    = string
  default = "admin"
}

variable "ssh_password" {
  type      = string
  default   = "hunter2"
  sensitive = true
}

source "proxmox-clone" "ubuntu-kvm64" {
  template_description = "VM Image based on Ubuntu Server 22.04 with Docker"

  # Proxmox Connection Settings
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_api_token_id}"
  token                    = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = false

  # Proxmox Build VM Settings
  node    = "${var.proxmox_node}"
  vm_name = "ubuntu-kvm64-docker"
  vm_id   = "${var.virtual_machine_id}"

  # VM OS Settings
  clone_vm_id = "${var.clone_vm_id}"

  memory   = 2048
  cores    = 2
  sockets  = 1
  cpu_type = "kvm64"
  os       = "l26"

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  scsi_controller = "virtio-scsi-pci"

  onboot     = false
  qemu_agent = true

  boot    = "order=virtio0;ide2;net0"
  machine = "q35"
  bios    = "ovmf"
  efi_config {
    efi_storage_pool  = "local"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  ssh_keypair_name       = "${var.ssh_keypair_name}"
  ssh_private_key_file   = "${var.ssh_private_key_file}"
  ssh_username           = "${var.ssh_username}"
  ssh_password           = "${var.ssh_password}"
  ssh_port               = 22
  ssh_timeout            = "3600s"
  ssh_handshake_attempts = 30
}

build {
  name = "ubuntu-kvm64-docker"
  sources = [
    "source.proxmox-clone.ubuntu-kvm64"
  ]

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
  }
}