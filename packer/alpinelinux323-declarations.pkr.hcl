##################################################################################
# LOCALS
##################################################################################

# HTTP Settings

locals {
  alpinelinux_version_major_minor = join(".", slice(split(".", var.vm_guest_os_version), 0, 2))
  alpinelinux_iso_name_x86_64 = "alpine-standard-${var.vm_guest_os_version}-x86_64.iso"
  alpinelinux_iso_url_x86_64 = "https://dl-cdn.alpinelinux.org/alpine/v${local.alpinelinux_version_major_minor}/releases/x86_64/${local.alpinelinux_iso_name_x86_64}"
  alpinelinux_iso_checksum_x86_64 = "sha256:${var.vm_guest_iso_checksum_x86_64}"
}

local "http_directory" {
  expression = "${path.root}/http"
}

# Virtual Machine Settings

locals { 
  vm_nonroot_shutdown_command = "echo '${var.vm_ssh_password}'|sudo -S /sbin/poweroff"
} 


# Non-interactive installation approach using answerfile
local "alpinelinux_boot_command_x86_64" {
  expression = [
    "<wait1.5m>", # Wait for system boot
    "root<enter><wait2>", # Login as root (no password on live ISO)
    "ip link set eth0 up<enter><wait2>", # Bring interface up to reach Packer HTTP server
    "udhcpc -i eth0<enter><wait10>", # Request new DHCP lease in Packer network
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answerfile<enter><wait5>", # Download answerfile from Packer HTTP server
    "EXPECTED='${var.vm_answerfile_checksum}'; ACTUAL=$(sha256sum answerfile | awk '{print $1}'); if [ \"$EXPECTED\" = \"$ACTUAL\" ]; then echo 'Checksum verified'; else echo \"ERROR: Answerfile checksum mismatch\"; echo \"Expected: $EXPECTED\"; echo \"Actual:   $ACTUAL\"; while true; do sleep 5; done; fi<enter><wait5>", # Verify answerfile checksum, loop forever on failure to trigger timeout
    "ERASE_DISKS=/dev/sda setup-alpine -f answerfile<enter><wait30>", # Run setup-alpine with answerfile (ERASE_DISKS suppresses confirmation)
    "${var.vm_ssh_password}<enter><wait2>", # Set root password (currently not supported in answerfile)
    "${var.vm_ssh_password}<enter><wait2>", # Retype password
    "<wait1m>", # Wait until installation is finished
    "reboot<enter><wait1.5m>", # Reboot into installed system
    "${var.vm_ssh_username}<enter><wait2>", # Login using root user
    "${var.vm_ssh_password}<enter><wait2>",
    "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config<enter><wait2>", # Allow root password login
    "echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config<enter><wait2>",
    "reboot<enter>"
  ]
}

# VirtualBox Settings

locals {
    vbox_output_name = "${var.vm_name}-virtualbox-amd64"
    vbox_post_shared_folder_path_full = "${ var.HOME }/${ var.vbox_post_shared_folder_path }"
}

##################################################################################
# VARIABLE DECLARATIONS
##################################################################################

# Environment Variables

variable "HOME" {
  description = "The user's home directory"
  type = string
  default = env("HOME")
}

# Virtual Machine Settings
variable "vm_name" {
  description = "Name of the VM"
  type = string
  default = ""
}

variable "vm_hostname" {
  type        = string
  description = "The hostname of the VM"
}

variable "vm_guest_os_version" {
  description = "Version of guest os to install"
  type = string
  default = ""
}

variable "vm_guest_iso_checksum_x86_64" {
  description = "Checksum of the iso installer"
  type        = string
  default     = ""
}

variable "vm_answerfile_checksum" {
  description = "SHA256 checksum of the rendered answerfile"
  type        = string
  default     = ""
}

variable "vm_boot_wait" {
  description = "Time to wait before typing the boot command"
  type = string
  default = ""
}

variable "vm_cpu_core" {
  description = "The number of virtual cpus"
  type = number
}

variable "vm_mem_size" {
  description = "The amount of memory in MB"
  type = number
}

variable "vm_root_shutdown_command" {
  description = "The command to use to gracefully shut down the VM"
  type = string
  default = ""
}

variable "vm_disk_size" {
  description = "The size of the disk to create in MB"
  type = number
}

variable "vm_ssh_timeout" {
  description = "The time to wait for SSH to become available"
  type = string
  default = ""
}

variable "vm_ssh_port" {
  description = "The port to use for SSH"
  type = number
}

variable "vm_ssh_username" {
  description = "The username to use for SSH connection"
  type = string
  default = ""
}

variable "vm_ssh_password" {
  description = "The password to use for SSH connection"
  type = string
  default =  ""
}


# VirtualBox Settings

variable "vbox_vm_headless" {
  description = "Run the VM in headless mode"
  type = bool
  default = true
}

variable "vbox_guest_additions" {
  description = "Install the VirtualBox Guest Additions"
  type = string
  default = ""
}

variable "vbox_post_cpu_core" {
  description = "The number of virtual cpus after the VM has been created"
  type = number
}

variable "vbox_post_mem_size" {
  description = "The amount of memory in MB after the VM has been created"
  type = number
}

variable "vbox_post_bridged_adapter" {
  description = "The bridged network adapter to use after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_graphics" {
  description = "The graphics controller to use after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_vram" {
  description = "The amount of video memory to use after the VM has been created"
  type = number
}

variable "vbox_post_accelerate_3d" {
  description = "Enable 3D acceleration after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_clipboard_mode" {
  description = "The clipboard mode to use after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_shared_folder_name" {
  description = "The name of the shared folder to create after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_shared_folder_path" {
  description = "The path of the shared folder to create after the VM has been created"
  type = string
  default = ""
}

variable "vbox_post_shared_folder_mount_point" {
  description = "The mount point of the shared folder to create after the VM has been created"
  type = string
  default = ""
}

variable "vbox_output_format" {
  description = "The format of the output"
  type = string
  default = ""
}
