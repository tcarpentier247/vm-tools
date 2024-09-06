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
  default = "packer-uefi-sol114.qcow2"
}

variable "solaris_iso_file" {
  type    = string
  default = "../images/sol-11_4-text-x86.iso"
}

source "qemu" "custom_image" {
  boot_command            = [
        "27<enter><wait>",
        "3<enter><wait10>",
        "<wait10>",
        "<wait10>",
        "<wait10>",
        "1<enter><wait10><wait10><wait10><wait10>",
        "<f2><wait5s>",
        "<f2><wait5s>",
        "<f2><wait5s>",
        "<f2><wait5s>",
        "-kvm<wait5s><f2>",
        "<f2><wait5s>",
        "<f2><wait5s><down><down><down><down><down><down><down><f2><wait5s>",
        "<down><down><down><down><down><down><down><down><down><down><down><down><down><down><f2><wait5s>",
        "<f2><wait5s>",
        "<f2><wait5s>",
        "<f2><wait5s>",
        "<f2><wait5s>",
        "<f2><wait5s>",
        "1opensvcpacker<tab><wait>",
        "1opensvcpacker<tab><wait>",
        "packer<tab><wait>",
        "packer<tab><wait>",
        "1opensvcpacker<tab><wait>",
        "1opensvcpacker<tab><wait>",
        "<f2><wait>",
        "<f2><wait>",
        "<f2><wait>",
        "<f2><wait>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10>",
        "<f8><wait10><wait10>",
	"<enter><wait10>",
        "<wait10><wait10><wait10><wait10><wait10><wait10>",
	"<wait10><wait10><wait10><wait10><wait10><wait10>",
        "<wait10><wait10><wait10><wait10><wait10>",
        "packer<enter><wait>",
        "1opensvcpacker<enter><wait>",
        "sudo bash<enter><wait>",
	"1opensvcpacker<enter><wait>",
	"echo 'packer ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers<enter><wait>",
	"/usr/gnu/bin/sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers<enter><wait>",
        "exit<enter><wait>"
      ]
  boot_wait               = "80s"
  iso_checksum            = "sha256:ee0bc41004f424a55cd0474a678c9e39df5a0afc600f8d737de842e50fd45cf0"
  iso_url                 = "./${var.solaris_iso_file}"
  shutdown_command        = "sudo /usr/sbin/init 5"
  ssh_password            = "1opensvcpacker"
  ssh_port                = 22
  ssh_username            = "packer"
  ssh_timeout = "40m"

  headless = true
  accelerator = "kvm"
  format = "qcow2"
  disk_size = "25G"
  disk_interface = "ide"
  net_device = "e1000"
  cpus = 2
  memory = 4096
  vnc_bind_address = "0.0.0.0"
  vnc_port_min = "22291"
  vnc_port_max = "22291"

  efi_boot = true
  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd"

  qemuargs = [
    ["-accel", "kvm"],
    ["-cpu", "host,-x2apic"],
    ["-machine", "usb=off"],
    ["-smp", "4,sockets=4,cores=1,threads=1"],
  ] 

  vm_name                 = "${var.vm_template_name}"
}

build {
  sources = [ "source.qemu.custom_image" ]
  provisioner "shell" {
    execute_command = "echo '1opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "./scripts/update.sh"
  }
  provisioner "file" {
    source = "./files/ansible.cfg"
    destination = "/export/home/packer/.ansible.cfg"
  }
  provisioner "shell" {
    expect_disconnect = "true"
    execute_command   = "echo '1opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script            = "../common/reboot.sh"
  }
  provisioner "shell" {
    pause_before    = "2m0s"
    execute_command = "echo '1opensvcpacker' | {{ .Vars }} sudo -S -H -E bash '{{ .Path }}'"
    script = "./scripts/software.sh"
  }
  provisioner "breakpoint" {
    disable = true
    note    = "this is a breakpoint"
  }
  provisioner "ansible-local" {
    playbook_file = "../common/ansible/env.yml"
    galaxy_file = "../common/ansible/requirements.yml"
  }
  provisioner "shell" {
    execute_command = "echo '1opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script          = "../common/git-clone-vmtools.sh"
  }
  provisioner "shell" {
    inline = [
      "cd /opt/vm-tools/build/common/ansible && sudo ./bootstrap.sh"
    ]
  }
  provisioner "shell" {
    execute_command = "echo '1opensvcpacker' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    script = "../common/custom/custom.sh"
  }
  provisioner "file" {
    source = "./files/S01osvcconfig"
    destination = "/tmp/S01osvcconfig"
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/S01osvcconfig /etc/rc2.d/ && sudo chown root:root /etc/rc2.d/S01osvcconfig"
    ]
  }
  provisioner "file" {
    source = "./files/S99reboot"
    destination = "/tmp/S99reboot"
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/S99reboot /etc/rc3.d/ && sudo chown root:root /etc/rc3.d/S99reboot"
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /export/home/packer/machines && sudo chown packer /export/home/packer/machines"
    ]
  }
  # upload machines ssh host keys
  # hostname is not known at this time
  provisioner "file" {
    source = "../../configs/machines/"
    destination = "/export/home/packer/machines/"
  }
  provisioner "file" {
    source = "/data/nfsshare/solaris/flash-archives/skelzone10-opensvc@provision"
    destination = "/var/tmp/skelzone10-opensvc@provision"
  }
  provisioner "shell" {
    execute_command = "echo '1opensvcpacker' | {{ .Vars }} sudo -S -H -E bash '{{ .Path }}'"
    script = "./scripts/zone.sh"
  }
  provisioner "shell" {
    execute_command   = "echo '1opensvcpacker' | {{ .Vars }} sudo -S -H -E bash '{{ .Path }}'"
    script            = "../common/solaris-cleanup.sh"
  }
  provisioner "breakpoint" {
    disable = true
    note    = "this is a breakpoint"
  }
}
