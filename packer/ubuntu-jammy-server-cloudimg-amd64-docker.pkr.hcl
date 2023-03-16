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

source "proxmox-clone" "ubuntu-jammy-server-cloudimg-amd64-docker" {
  template_description = "VM Image based on Ubuntu Server 22.04 with Docker"

  # Proxmox Connection Settings
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_api_token_id}"
  token                    = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = false

  # Proxmox Build VM Settings
  node    = "${var.proxmox_node}"
  vm_name = "ubuntu-jammy-server-cloudimg-amd64-docker"
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

  cloud_init              = true
  cloud_init_storage_pool = "local"

  boot    = "c"
  machine = "q35"
  bios    = "ovmf"
  efi_config {
    efi_storage_pool  = "local"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  http_directory = "http"
  http_interface = "vmbr0"
  http_port_min  = 8802
  http_port_max  = 8802

  ssh_keypair_name       = "${var.ssh_keypair_name}"
  ssh_private_key_file   = "${var.ssh_private_key_file}"
  ssh_username           = "${var.ssh_username}"
  ssh_password           = "${var.ssh_password}"
  ssh_port               = 22
  ssh_timeout            = "3600s"
  ssh_handshake_attempts = 30
}

build {
  name    = "ubuntu-jammy-server-cloudimg-amd64-docker"
  sources = ["source.proxmox-clone.ubuntu-jammy-server-cloudimg-amd64-docker"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo truncate -s 0 /etc/machine-id"
    ]
  }

  provisioner "shell" {
    inline = [
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get -y update",
      "sudo apt-get -y install docker-ce docker-ce-cli containerd.io",
      "sudo apt-get -y clean",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
    ]
  }
}