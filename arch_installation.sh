#!/usr/bin/env bash

echo "\nThis is a arch installation script for UEFI installations in the virtual machine without a GUI.\n"

# Let's get the details needed to create the GPT partition table. (EFI partition, SWAP partition, ROOT partition)

echo "Please enter the disk: (eg: /dev/sda)"
read DISK

echo "Please enter EFI parition: (eg: /dev/sda1)"
read EFI

echo "Please enter SWAP parition: (eg: /dev/sda2)"
read SWAP

echo "Please enter ROOT parition: (eg: /dev/sda3)"
read ROOT

# Let's set up a password for the installation
PASSWORD="arch@123"

# Let's create the filesystem now.
echo "\nCreating the file system.\n"

# Let's create the partion table and partions using fdsik.
fdisk "${DISK}"

# Let's format the ROOT and SWAP paritions.

mkfs.ext4 "${ROOT}"
mkswap "${SWAP}"

# Let's format the EFI system parition.
mkfs.fat -F 32 "${EFI}"

echo "\nLet's mount the file system.\n"

mount "${ROOT}" /mnt
mount --mkdir "${EFI}" /mnt/boot

echo "\nLet's enable the swap parition.\n"

swapon "${SWAP}"

echo "\nNow let's install the base packages and other utilities\n"

pacstrap -K /mnt base linux linux-firmware man-db net-tools networkmanager grub efibootmgr vim sudo

echo "\n\nNow let's configure the system!"

echo "\nGenerate the fstab!"

genfstab -U /mnt >> /mnt/etc/fstab

echo "\nChange root into new system"

arch-chroot /mnt /bin/bash <<EOF


# Set up the timezone
echo "\nSet up the time zone"

ln -sf /usr/share/zoneinfo/Asia/Colombo /etc/localtime

hwclock --systohc

# Set locles
locale-gen
touch /etc/locale.conf
echo "LANG=en_us.UTF-8" > /etc/locale.conf

# creting a hostname
touch /etc/hostname
echo "myarch" >> /etc/hostname

cat <<EOL > /etc/hosts
127.0.0.1	localhost
127.0.1.1	myarch
::1     ip6-localhost ip6-loopback
EOL

mkinitcpio -P

# Boot Loader
grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

passwd

EOF
