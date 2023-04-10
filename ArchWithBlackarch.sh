#!/bin/bash

read -p "Gebe die Partitionsgröße in GB ein (z. B. 50): " PARTITION_SIZE

# Determine if UEFI or BIOS boot mode
if [ -d "/sys/firmware/efi/" ]; then
  BOOT_MODE="UEFI"
else
  BOOT_MODE="BIOS"
fi

# Partition the storage
if [ "$BOOT_MODE" == "UEFI" ]; then
  parted /dev/sda mklabel gpt
  parted /dev/sda mkpart ESP fat32 1MiB 513MiB
  parted /dev/sda set 1 boot on
  parted /dev/sda mkpart primary ext4 513MiB ${PARTITION_SIZE}GB
  mkfs.fat -F32 /dev/sda1
  mkfs.ext4 /dev/sda2
else
  parted /dev/sda mklabel msdos
  parted /dev/sda mkpart primary ext4 1MiB ${PARTITION_SIZE}GB
  mkfs.ext4 /dev/sda1
fi

# Mount the partition
mount /dev/sda2 /mnt

# Install Arch Linux and KDE, excluding games packages
pacstrap /mnt base base-devel kde-applications kde-frameworks
sed -i '/games/d' /mnt/etc/pacman.conf

# Add the BlackArch repository
echo "[BlackArch]" >> /mnt/etc/pacman.conf
echo "Server = https://mirror.0x.sg/blackarch/\$repo/os/\$arch" >> /mnt/etc/pacman.conf

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new installation
arch-chroot /mnt

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Localization
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" > /etc/locale.conf

# Keyboard layout
echo "KEYMAP=de-latin1" > /etc/vconsole.conf

# Create user account
read -p "Geben Sie den Benutzernamen ein: " USERNAME
useradd -m -g users -G wheel,audio,video -s /bin/bash $USERNAME
passwd $USERNAME

# Network configuration
echo "MyHostname" > /etc/hostname

# Install BlackArch tools
pacman -Sy blackarch

# Boot loader
if [ "$BOOT_MODE" == "UEFI" ]; then
  pacman -S grub efibootmgr
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg
else
  pacman -S grub
  grub-install /dev/sda
  grub-mkconfig -o /boot/grub/grub.cfg
fi

# Exit chroot and reboot
exit
umount /mnt
reboot
