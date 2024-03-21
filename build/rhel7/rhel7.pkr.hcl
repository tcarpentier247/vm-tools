packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "vm_template_name" {
  type    = string
  default = "packer-uefi-rhel-7.qcow2"
}

variable "rhel_iso_file" {
  type    = string
  default = "rhel-server-7.9-x86_64-dvd.iso"
}

variable "RHN_ORG" {
  type    = string
  default = "undefined"
}

variable "RHN_KEY" {
  type    = string
  default = "undefine" 
}

source "qemu" "custom_image" {

  boot_command = [
    "<esc>c",
    "linuxefi /images/pxeboot/vmlinuz inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks7.cfg<enter>",
    "initrdefi /images/pxeboot/initrd.img<enter>",
    "boot<enter>",
    "<wait>4"
  ]
  boot_wait = "10s"

  http_directory = "http"
  iso_url   = "../images/${var.rhel_iso_file}"
  iso_checksum = "none"
  memory = 4096

  ssh_password = "opensvcpacker"
  ssh_username = "packer"
  ssh_timeout = "20m"
  ssh_port = 22
  shutdown_command = "echo 'opensvcpacker' | sudo -S shutdown -P now"

  headless = true
  accelerator = "kvm"
  format = "qcow2"
  disk_cache = "none"
  disk_discard = "unmap"
  disk_size = "20G"
  disk_interface = "virtio"
  net_device = "virtio-net"
  cpus = 4

  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "32000"
  vnc_port_max = "32001"

  qemuargs = [
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
    ["-accel", "kvm"],
    ["-cpu", "host"],
    ["-machine", "pc-q35-6.2,usb=off,vmport=off,dump-guest-core=off"],
    ["-smp", "4,sockets=4,cores=1,threads=1"],
  ]

  vm_name = "${var.vm_template_name}"
}

build {
  sources = [ "source.qemu.custom_image" ]
  provisioner "shell" {
    environment_vars = [
     "RHN_ORG=${var.RHN_ORG}",
     "RHN_KEY=${var.RHN_KEY}"
    ]
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/rhel-register.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/rhel-update.sh"
  }
  provisioner "breakpoint" {
    disable = false
    note    = "breakpoint before ansible install"
  }
    provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "./scripts/ansible.sh"
  }
  provisioner "breakpoint" {
    disable = false
    note    = "this is a breakpoint"
  }
  provisioner "ansible-local" {
    playbook_file  = "../common/main.yml"
    galaxy_file    = "../common/requirements.yml"
    galaxy_command = "ansible-galaxy-3"
    command = "ansible-playbook-3"
    #extra_arguments = ["--extra-vars", "\"pizza_toppings=${var.topping}\""]
  }
  provisioner "shell" {
    expect_disconnect = true
    execute_command   = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script            = "../common/reboot.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    pause_before    = "1m0s"
    script          = "./scripts/zfs.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "./scripts/drbd.sh"
  }
  provisioner "breakpoint" {
    disable = true
    note    = "this is a breakpoint"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/rhel-unregister.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/rhel-cleanup.sh"
  }
}
