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
  default = "packer-sles12sp5.qcow2"
}

variable "sles12_iso_file" {
  type    = string
  default = "SLE-12-SP5-Server-DVD-x86_64-GM-DVD1.iso"
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
    "<esc><enter><wait>",
    "linux netdevice=eth0 netsetup=dhcp install=cd:/",
    " lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles12-autoinst.xml",
    " textmode=1",
    "<enter><wait>"
  ]
  boot_wait = "10s"
  
  http_directory = "http"
  iso_url   = "file:///data/vdc/build/images/${var.sles12_iso_file}"
  iso_checksum = "file:file:///data/vdc/build/images/${var.sles12_iso_file}.sha256"
  memory = 4096
  
  ssh_password = "opensvcpacker"
  ssh_username = "packer"
  ssh_timeout = "20m"
  ssh_port = 22
  shutdown_command = "echo 'opensvcpacker' | sudo -S shutdown -P now"

  headless = true
  accelerator = "kvm"
  format = "qcow2"
  disk_size = "20G"
  disk_interface = "virtio"
  disk_discard = "unmap"
  disk_detect_zeroes = "unmap"
  net_device = "virtio-net"
  cpus = 4
  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "32014"
  vnc_port_max = "32014"

  qemuargs = [
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
    script = "../common/sles-snapper.sh"
  }
  provisioner "breakpoint" {
    disable = true
    note    = "Troubleshooting Breakpoint"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-ansible.sh"
  }
  provisioner "shell" {
    execute_command = "echo 'opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/sles-cloud-init.sh"
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
