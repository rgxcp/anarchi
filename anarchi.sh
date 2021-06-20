#!/bin/bash

pre_installation () {
    echo "╔══════════════════╗"
    echo "║ █▀▀█ ▒█▀▀█ ▒█▀▀▀ ║"
    echo "║ █▄▄█ ▒█▄▄▀ ▒█▀▀▀ ║"
    echo "║ █░░░ ▒█░▒█ ▒█▄▄▄ ║"
    echo "║   Installation   ║"
    echo "╚══════════════════╝"

    echo "Step 1.1 - Downloading ISO & Signature File"
    read -p "ISO file HTTP direct link: " ISO_FILE_LINK
    read -p "ISO file name: " ISO_FILE_NAME
    echo "COMMAND: cd $HOME/Downloads"
    cd $HOME/Downloads
    echo "COMMAND: curl -O $ISO_FILE_LINK"
    curl -O $ISO_FILE_LINK
    echo "COMMAND: curl -O $ISO_FILE_LINK.sig"
    curl -O $ISO_FILE_LINK.sig
    read -p "Press enter to continue."
    echo ""

    echo "Step 1.2 - Verifying ISO File with GPG"
    echo "COMMAND: gpg --keyserver-options auto-key-retrieve --verify $ISO_FILE_NAME.sig"
    gpg --keyserver-options auto-key-retrieve --verify $ISO_FILE_NAME.sig
    read -p "Please make sure the signature is good. Press enter to continue."
    echo ""

    echo "Step 1.3 - Verifying ISO File with Pacman"
    echo "COMMAND: pacman-key -v $ISO_FILE_NAME.sig"
    pacman-key -v $ISO_FILE_NAME.sig
    read -p "Please make sure the signature is good. Press enter to continue."
    echo ""

    echo "Step 1.4 - Making Bootable Flash Drive"
    read -p "Please insert the flash drive. Press enter to continue."
    echo "COMMAND: su -"
    su -
    echo "COMMAND: lsblk"
    lsblk
    read -p "Flash drive block: " FLASH_DRIVE_BLOCK
    echo "COMMAND: mkfs.vfat -I $FLASH_DRIVE_BLOCK"
    mkfs.vfat -I $FLASH_DRIVE_BLOCK
    echo "COMMAND: lsblk"
    lsblk
    read -p "Please make sure the flash drive is properly formatted. Press enter to continue."
    echo "COMMAND: dd if=$HOME/Downloads/$ISO_FILE_NAME of=$FLASH_DRIVE_BLOCK bs=4M status=progress && sync"
    dd if=$HOME/Downloads/$ISO_FILE_NAME of=$FLASH_DRIVE_BLOCK bs=4M status=progress && sync
    echo "COMMAND: lsblk"
    lsblk
    read -p "Please make sure the flash drive is properly installed. Press enter to continue."
    echo ""

    echo "Step 1.5 - Shutting Down System"
    read -p "Turn off & on system manually, configure boot priority, and boot into flash drive. Press enter to continue."
}

main_installation () {
    echo "╔═════════════════════════╗"
    echo "║ ▒█▀▄▀█ ░█▀▀█ ▀█▀ ▒█▄░▒█ ║"
    echo "║ ▒█▒█▒█ ▒█▄▄█ ▒█░ ▒█▒█▒█ ║"
    echo "║ ▒█░░▒█ ▒█░▒█ ▄█▄ ▒█░░▀█ ║"
    echo "║      Installation       ║"
    echo "╚═════════════════════════╝"

    echo "Step 2.1 - Verifying Boot Mode"
    echo "COMMAND: ls /sys/firmware/efi/efivars"
    ls /sys/firmware/efi/efivars
    read -p "Please make sure the EFI files is exists. Press enter to continue."
    echo ""

    echo "Step 2.2 - Updating System Clock"
    echo "COMMAND: timedatectl set-ntp true"
    timedatectl set-ntp true
    echo "COMMAND: timedatectl status"
    timedatectl status
    read -p "Please make sure the system clock is correct. Press enter to continue."
    echo ""

    echo "Step 2.3 - Partitioning Drive"
    echo "1. [p]rint the partition table."
    echo "2. [d]elete all partitions."
    echo "3. [p]rint the partition table again."
    echo "4. [g]enerate a new GPT partition table."
    echo "5. [n]ew a +500M partition."
    echo "6. [t]ype the new partition to 1."
    echo "7. [n]ew a +8G partition."
    echo "8. [t]ype the new partition to 19."
    echo "9. [n]ew a +remaining partition."
    echo "10.[t]ype the new partition to 23."
    echo "11.[p]rint the partition table again."
    echo "12.[w]rite table to disk and exit."
    read -p "Press enter to continue."
    echo "COMMAND: lsblk"
    lsblk
    read -p "Drive block: " DRIVE_BLOCK
    echo "COMMAND: fdisk $DRIVE_BLOCK"
    fdisk $DRIVE_BLOCK

    echo "Step 2.4 - Formatting Partitions"
    echo "COMMAND: mkfs.fat -F32 ${DRIVE_BLOCK}1"
    mkfs.fat -F32 ${DRIVE_BLOCK}1
    echo "COMMAND: mkswap ${DRIVE_BLOCK}2"
    mkswap ${DRIVE_BLOCK}2
    echo "COMMAND: mkfs.ext4 ${DRIVE_BLOCK}3"
    mkfs.ext4 ${DRIVE_BLOCK}3
    read -p "Press enter to continue."
    echo ""

    echo "Step 2.5 - Mounting Partitions"
    echo "COMMAND: mount ${DRIVE_BLOCK}3 /mnt"
    mount ${DRIVE_BLOCK}3 /mnt
    echo "COMMAND: swapon ${DRIVE_BLOCK}2"
    swapon ${DRIVE_BLOCK}2
    echo "COMMAND: mkdir /mnt/boot"
    mkdir /mnt/boot
    echo "COMMAND: mount ${DRIVE_BLOCK}1 /mnt/boot"
    mount ${DRIVE_BLOCK}1 /mnt/boot
    echo "COMMAND: lsblk"
    lsblk
    read -p "Please make sure the partitions is properly mounted. Press enter to continue."
    echo ""

    echo "Step 2.6 - Installing Essential Packages"
    echo "COMMAND: pacstrap /mnt base linux linux-firmware"
    pacstrap /mnt base linux linux-firmware
    read -p "Press enter to continue."
    echo ""

    echo "Step 2.7 - Generating Fstab"
    echo "COMMAND: genfstab -U /mnt >> /mnt/etc/fstab"
    genfstab -U /mnt >> /mnt/etc/fstab
    read -p "Press enter to continue."
    echo ""

    echo "Step 2.8 - Entering Arch"
    read -p "Enter Arch manually with COMMAND: arch-chroot /mnt. Press enter to continue."
}

post_installation () {
    echo "╔═══════════════════════════╗"
    echo "║ ▒█▀▀█ ▒█▀▀▀█ ▒█▀▀▀█ ▀▀█▀▀ ║"
    echo "║ ▒█▄▄█ ▒█░░▒█ ░▀▀▀▄▄ ░▒█░░ ║"
    echo "║ ▒█░░░ ▒█▄▄▄█ ▒█▄▄▄█ ░▒█░░ ║"
    echo "║       Installation        ║"
    echo "╚═══════════════════════════╝"

    echo "Step 3.1 - Configuring Time Zone"
    echo "COMMAND: ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime"
    ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    echo "COMMAND: hwclock --systohc"
    hwclock --systohc
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.2 - Configuring Localization"
    echo "COMMAND: sed -i "\""s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/"\"" /etc/locale.gen"
    sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
    echo "COMMAND: locale-gen"
    locale-gen
    echo "COMMAND: echo "\""LANG=en_US.UTF-8"\"" > /etc/locale.conf"
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.3 - Configuring Host Name & Network"
    read -p "Host name: " HOST_NAME
    echo "COMMAND: echo "\""$HOST_NAME"\"" > /etc/hostname"
    echo "$HOST_NAME" > /etc/hostname
    echo "COMMAND: echo -e "\""\n127.0.0.1\tlocalhost\n::1\t\t\tlocalhost\n127.0.1.1\t$HOST_NAME.localdomain\t$HOST_NAME"\"" >> /etc/hosts"
    echo -e "\n127.0.0.1\tlocalhost\n::1\t\t\tlocalhost\n127.0.1.1\t$HOST_NAME.localdomain\t$HOST_NAME" >> /etc/hosts
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.4 - Creating Initramfs"
    echo "COMMAND: mkinitcpio -P"
    mkinitcpio -P
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.5 - Configuring Root Password"
    echo "COMMAND: passwd"
    passwd
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.6 - Installing Essential Packages"
    echo "COMMAND: pacman -S efibootmgr grub networkmanager"
    pacman -S efibootmgr grub networkmanager
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.7 - Installing & Configuring GRUB"
    echo "COMMAND: grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB"
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    echo "COMMAND: grub-mkconfig -o /boot/grub/grub.cfg"
    grub-mkconfig -o /boot/grub/grub.cfg
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.8 - Enabling NetworkManager"
    echo "COMMAND: systemctl enable NetworkManager"
    systemctl enable NetworkManager
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.9 - Disabling PC Speaker"
    echo "COMMAND: echo "\""blacklist pcspkr"\"" > /etc/modprobe.d/nobeep.conf"
    echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.10 - Exiting Arch"
    read -p "Exit Arch manually with COMMAND: exit. Press enter to continue."
}

finish_installation () {
    echo "╔═══════════════════════════════════╗"
    echo "║ ▒█▀▀▀ ▀█▀ ▒█▄░▒█ ▀█▀ ▒█▀▀▀█ ▒█░▒█ ║"
    echo "║ ▒█▀▀▀ ▒█░ ▒█▒█▒█ ▒█░ ░▀▀▀▄▄ ▒█▀▀█ ║"
    echo "║ ▒█░░░ ▄█▄ ▒█░░▀█ ▄█▄ ▒█▄▄▄█ ▒█░▒█ ║"
    echo "║           Installation            ║"
    echo "╚═══════════════════════════════════╝"

    echo "Step 4.1 - Unmounting Partitions"
    echo "COMMAND: umount -R /mnt"
    umount -R /mnt
    echo "COMMAND: lsblk"
    lsblk
    read -p "Please make sure the partitions is properly unmounted. Press enter to continue."
    echo ""

    echo "Step 4.2 - Rebooting System"
    read -p "Reboot system manually with COMMAND: reboot, configure boot priority, and boot into Arch. Press enter to continue."
}

unknown_choice () {
    echo "ERROR: Unknown choice."
}

main () {
    echo "╔══════════════════════════════════════════╗"
    echo "║ ░█▀▀█ ▒█▄░▒█ ░█▀▀█ ▒█▀▀█ ▒█▀▀█ ▒█░▒█ ▀█▀ ║"
    echo "║ ▒█▄▄█ ▒█▒█▒█ ▒█▄▄█ ▒█▄▄▀ ▒█░░░ ▒█▀▀█ ▒█░ ║"
    echo "║ ▒█░▒█ ▒█░░▀█ ▒█░▒█ ▒█░▒█ ▒█▄▄█ ▒█░▒█ ▄█▄ ║"
    echo "║         An Arch Installer v1.0.0         ║"
    echo "╚══════════════════════════════════════════╝"

    echo "1. Pre Installation"
    echo "2. Main Installation"
    echo "3. Post Installation"
    echo "4. Finish Installation"
    read -p "Enter your choice: " CHOICE
    echo ""

    case $CHOICE in
        "1") pre_installation;;
        "2") main_installation;;
        "3") post_installation;;
        "4") finish_installation;;
        "") unknown_choice;;
        *) unknown_choice;;
    esac
}

main
