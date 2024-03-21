packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "vm_template_name" {
  type    = string
  default = "packer-uefi-sles15sp5.qcow2"
}

variable "sles15_iso_file" {
  type    = string
  default = "SLE-15-SP5-Full-x86_64-GM-Media1.iso"
}

variable "suse_key" {
  type    = string
  default = "undefined"
}

variable "suse_email" {
  type    = string
  default = "undefined"
}

source "qemu" "custom_image" {
  
  boot_command = [
    "e<wait>",
    "<down><down><down><down><wait>",
    "<end><wait>",
    " netdevice=eth0 netsetup=dhcp install=cd:/",
    " lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles15-autoinst.xml",
    " textmode=1",
    "<f10><wait>"
  ]
  boot_wait = "5s"
  
  http_directory = "http"
  iso_url   = "file:///data/vdc/build/images/${var.sles15_iso_file}"
  iso_checksum = "file:file:///data/vdc/build/images/${var.sles15_iso_file}.sha256"
  memory = 4096
  
  ssh_password = "opensvcpacker"
  ssh_username = "packer"
  ssh_timeout = "20m"
  ssh_port = 22
  shutdown_command = "echo 'opensvcpacker' | sudo -S shutdown -P now"

  headless = true
  accelerator = "kvm"
  format = "qcow2"
  disk_size = "50G"
  disk_interface = "virtio"
  net_device = "virtio-net"
  cpus = 4
  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "32015"
  vnc_port_max = "32015"

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
      "SUSE_KEY=${var.suse_key}",
      "SUSE_EMAIL=${var.suse_email}"
    ]
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-register.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-update.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-ansible.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-cloud-init.sh"
  }
  provisioner "breakpoint" {
    disable = true
    note    = "Troubleshooting Breakpoint"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = "true"
    script          = "../common/reboot.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    pause_before    = "1m0s"
    script = "../common/sles-zfs.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-drbd.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-unregister.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-cleanup.sh"
  }
}
