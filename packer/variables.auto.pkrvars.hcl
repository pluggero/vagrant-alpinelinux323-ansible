##################################################################################
# VARIABLE DEFINITIONS
##################################################################################

# Virtual Machine Settings
vm_name                             = "alpinelinux323"
vm_hostname                         = "alpinelinux323-ansible"
vm_guest_os_version                 = "3.23.3"
vm_guest_iso_checksum_x86_64        = "1b8be1ce264bf50048f2c93d8b4e72dd0f791340090aaed022b366b9a80e3518"
# You can get the checksum manually with this command: echo 'sha256(templatefile("http/answerfile.pkrtpl.hcl", { hostname = var.vm_hostname }))' | packer console packer/
vm_answerfile_checksum              = "fcc5fa5c4daa6f74c19f0b52a1922bb6ee4bcddb6fd0364d43798b16c603a6dd"
vm_boot_wait                        = "10s"
vm_cpu_core                         = 4
vm_mem_size                         = 4096
vm_root_shutdown_command            = "/sbin/poweroff"
vm_disk_size                        = 16000
vm_ssh_port                         = 22
vm_ssh_timeout                      = "1800s"
vm_ssh_username                     = "root"
vm_ssh_password                     = "vagrant"

# VirtualBox Settings
vbox_vm_headless                    = true
vbox_guest_additions                = "disable"
vbox_output_format                  = "ovf"

# VirtualBox Post-Processing Settings
vbox_post_cpu_core                  = 1
vbox_post_mem_size                  = 1024
vbox_post_graphics                  = "vmsvga"
vbox_post_vram                      = 256
vbox_post_accelerate_3d             = "off"
vbox_post_clipboard_mode            = "bidirectional"
