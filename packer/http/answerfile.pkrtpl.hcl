# Automated answerfile for setup-alpine
# This file is processed by Packer's templatefile() function
# Variables: ${hostname} - injected from var.vm_hostname

# Use US layout with US international variant
KEYMAPOPTS="us us-intl"

# Set hostname from Packer variable
HOSTNAMEOPTS=${hostname}

# Set device manager to mdev
DEVDOPTS=mdev

# Network configuration
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
hostname ${hostname}
"

# Set timezone to UTC
TIMEZONEOPTS="UTC"

# No proxy
PROXYOPTS=none

# Add first mirror (CDN) and enable community repo
APKREPOSOPTS="-1 -c"

# No additional user
USEROPTS=none

# Install OpenSSH server
SSHDOPTS=openssh

# Use busybox ntp client
NTPOPTS="busybox"

# Install to /dev/sda as sys disk
DISKOPTS="-m sys /dev/sda"

# No additional storage configuration
LBUOPTS=none

# No APK cache
APKCACHEOPTS=none
