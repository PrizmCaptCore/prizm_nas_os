# remove list

cloud-init
archinstall
wvdial
ppp
pptpclient
vim
lynx
virtualbox-guest-utils-nox
qemu-guest-agent
sof-firmware
open-vm-tools
clonezilla
partclone
partimage
linux-firmware-marvell
bind
usbmuxd
memtest86+
memtest86+-efi
openconnect
vpnc
xl2tpd

## fs tool

nilfs-utils
jfsutils
f2fs-tools
bcachefs-tools

## legacy

linux-atm
# ============================================
# REMOVABLE PACKAGES
# (Can be commented out with # to reduce size)
# ============================================

# Sound (unnecessary for NAS)
# alsa-utils
# livecd-sounds

# Accessibility
# brltty
# espeakup
# gpm

# VM guests
bolt
hyperv

# Wireless (unnecessary for wired NAS)
iw
iwd
modemmanager
wireless-regdb
wireless_tools
wpa_supplicant

# Outdated hardware drivers
b43-fwcutter
broadcom-wl

# VPN
cryptsetup
openvpn

# HTTP server
darkhttpd

# Recovery tools
ddrescue
fsarchiver
gpart
testdisk

# DNS/Network tools
dnsmasq
ldns
ndisc6
nmap
tcpdump
systemd-resolvconf

# Uncommon filesystems
exfatprogs
fatresize
ntfs-3g
udftools

# Terminal emulators
foot-terminfo
kitty-terminfo
rxvt-unicode-terminfo

# Shell/Terminal multiplexers
grml-zsh-config
zsh
screen
tmux

# Text editors/file managers
man-db
man-pages
mc

# iSCSI/NFS/NBD
mkinitcpio-nfs-utils
nbd
nfs-utils
open-iscsi

# Misc tools
edk2-shell
irssi
lftp
libfido2
libusb-compat
lsscsi
mmc-utils
openpgp-card-tools
pcsclite
pv
refind
reflector
sdparm
sequoia-sq
sg3_utils
tpm2-tools
tpm2-tss
usb_modeswitch
usbutils
xdg-utils
dmidecode
dmraid
