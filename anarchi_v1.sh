#!/bin/bash

GREEN="\e[32m"
WHITE="\e[0m"

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
    echo -e "${GREEN}COMMAND: cd $HOME/Downloads${WHITE}"
    cd $HOME/Downloads
    echo -e "${GREEN}COMMAND: curl -O $ISO_FILE_LINK${WHITE}"
    curl -O $ISO_FILE_LINK
    echo -e "${GREEN}COMMAND: curl -O $ISO_FILE_LINK.sig${WHITE}"
    curl -O $ISO_FILE_LINK.sig
    read -p "Press enter to continue."
    echo ""

    echo "Step 1.2 - Verifying ISO File with GPG"
    echo -e "${GREEN}COMMAND: gpg --keyserver-options auto-key-retrieve --verify $ISO_FILE_NAME.sig${WHITE}"
    gpg --keyserver-options auto-key-retrieve --verify $ISO_FILE_NAME.sig
    read -p "Please make sure the signature was good. Press enter to continue."
    echo ""

    echo "Step 1.3 - Verifying ISO File with Pacman"
    echo -e "${GREEN}COMMAND: pacman-key -v $ISO_FILE_NAME.sig${WHITE}"
    pacman-key -v $ISO_FILE_NAME.sig
    read -p "Please make sure the signature was good. Press enter to continue."
    echo ""

    echo "Step 1.4 - Making Bootable Flash Drive"
    read -p "Please insert the flash drive. Press enter to continue."
    echo -e "${GREEN}COMMAND: lsblk${WHITE}"
    lsblk
    read -p "Flash drive block: " FLASH_DRIVE_BLOCK
    echo -e "${GREEN}COMMAND: sudo mkfs.vfat -I $FLASH_DRIVE_BLOCK${WHITE}"
    sudo mkfs.vfat -I $FLASH_DRIVE_BLOCK
    echo -e "${GREEN}COMMAND: lsblk${WHITE}"
    lsblk
    read -p "Please make sure the flash drive was properly formatted. Press enter to continue."
    echo -e "${GREEN}COMMAND: sudo dd if=$HOME/Downloads/$ISO_FILE_NAME of=$FLASH_DRIVE_BLOCK bs=4M status=progress && sync${WHITE}"
    sudo dd if=$HOME/Downloads/$ISO_FILE_NAME of=$FLASH_DRIVE_BLOCK bs=4M status=progress && sync
    echo -e "${GREEN}COMMAND: lsblk${WHITE}"
    lsblk
    read -p "Please make sure the flash drive was properly installed. Press enter to continue."
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
    echo -e "${GREEN}COMMAND: ls /sys/firmware/efi/efivars${WHITE}"
    ls /sys/firmware/efi/efivars
    read -p "Please make sure the EFI files was exists. Press enter to continue."
    echo ""

    echo "Step 2.2 - Updating System Clock"
    echo -e "${GREEN}COMMAND: timedatectl set-ntp true${WHITE}"
    timedatectl set-ntp true
    echo -e "${GREEN}COMMAND: timedatectl status${WHITE}"
    timedatectl status
    read -p "Please make sure the system clock was correct. Press enter to continue."
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
    echo -e "${GREEN}COMMAND: lsblk${WHITE}"
    lsblk
    read -p "Drive block: " DRIVE_BLOCK
    echo -e "${GREEN}COMMAND: fdisk $DRIVE_BLOCK${WHITE}"
    fdisk $DRIVE_BLOCK

    echo "Step 2.4 - Formatting Partitions"
    echo -e "${GREEN}COMMAND: mkfs.fat -F32 ${DRIVE_BLOCK}1${WHITE}"
    mkfs.fat -F32 ${DRIVE_BLOCK}1
    echo -e "${GREEN}COMMAND: mkswap ${DRIVE_BLOCK}2${WHITE}"
    mkswap ${DRIVE_BLOCK}2
    echo -e "${GREEN}COMMAND: mkfs.ext4 ${DRIVE_BLOCK}3${WHITE}"
    mkfs.ext4 ${DRIVE_BLOCK}3
    read -p "Press enter to continue."
    echo ""

    echo "Step 2.5 - Mounting Partitions"
    echo -e "${GREEN}COMMAND: mount ${DRIVE_BLOCK}3 /mnt${WHITE}"
    mount ${DRIVE_BLOCK}3 /mnt
    echo -e "${GREEN}COMMAND: swapon ${DRIVE_BLOCK}2${WHITE}"
    swapon ${DRIVE_BLOCK}2
    echo -e "${GREEN}COMMAND: mkdir /mnt/boot${WHITE}"
    mkdir /mnt/boot
    echo -e "${GREEN}COMMAND: mount ${DRIVE_BLOCK}1 /mnt/boot${WHITE}"
    mount ${DRIVE_BLOCK}1 /mnt/boot
    echo -e "${GREEN}COMMAND: lsblk${WHITE}"
    lsblk
    read -p "Please make sure the partitions was properly mounted. Press enter to continue."
    echo ""

    echo "Step 2.6 - Installing Essential Packages"
    echo -e "${GREEN}COMMAND: pacstrap /mnt base linux linux-firmware${WHITE}"
    pacstrap /mnt base linux linux-firmware
    read -p "Press enter to continue."
    echo ""

    echo "Step 2.7 - Generating Fstab"
    echo -e "${GREEN}COMMAND: genfstab -U /mnt >> /mnt/etc/fstab${WHITE}"
    genfstab -U /mnt >> /mnt/etc/fstab
    read -p "Press enter to continue."
    echo ""

    echo "Step 2.8 - Copying anarchi.sh into Arch"
    echo -e "${GREEN}COMMAND: cp anarchi.sh /mnt${WHITE}"
    cp anarchi.sh /mnt
    read -p "Press enter to continue."
    echo ""

    echo "Step 2.9 - Entering Arch"
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
    echo -e "${GREEN}COMMAND: ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime${WHITE}"
    ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    echo -e "${GREEN}COMMAND: hwclock --systohc${WHITE}"
    hwclock --systohc
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.2 - Configuring Localization"
    echo -e "${GREEN}COMMAND: sed -i "\""s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/"\"" /etc/locale.gen${WHITE}"
    sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
    echo -e "${GREEN}COMMAND: locale-gen${WHITE}"
    locale-gen
    echo -e "${GREEN}COMMAND: echo "\""LANG=en_US.UTF-8"\"" > /etc/locale.conf${WHITE}"
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.3 - Configuring Host Name & Network"
    read -p "Host name: " HOST_NAME
    echo -e "${GREEN}COMMAND: echo "\""$HOST_NAME"\"" > /etc/hostname${WHITE}"
    echo "$HOST_NAME" > /etc/hostname
    echo -e "${GREEN}COMMAND: echo -e "\""\n127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOST_NAME.localdomain\t$HOST_NAME"\"" >> /etc/hosts${WHITE}"
    echo -e "\n127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOST_NAME.localdomain\t$HOST_NAME" >> /etc/hosts
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.4 - Creating Initramfs"
    echo -e "${GREEN}COMMAND: mkinitcpio -P${WHITE}"
    mkinitcpio -P
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.5 - Configuring Root Password"
    echo -e "${GREEN}COMMAND: passwd${WHITE}"
    passwd
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.6 - Installing Essential Packages"
    PACKAGES=(
        alacritty
        alsa-utils
        arc-gtk-theme
        base-devel
        blueberry
        chntpw
        dolphin
        dosfstools
        dunst
        efibootmgr
        firefox
        git
        gnome-keyring
        grub
        htop
        lightdm
        lightdm-gtk-greeter
        lightdm-gtk-greeter-settings
        lxappearance
        nano
        neofetch
        networkmanager
        nitrogen
        ntfs-3g
        nvidia
        os-prober
        papirus-icon-theme
        pcmanfm
        picom
        playerctl
        python-pip
        python-pywal
        qbittorrent
        rofi
        scrot
        starship
        ttf-fira-code
        vlc
        xf86-video-intel
        xorg
        xorg-xinit
        youtube-dl
        zsh
        zsh-autosuggestions
        zsh-syntax-highlighting
    )
    echo -e "${GREEN}COMMAND: pacman -S ${PACKAGES[@]}${WHITE}"
    pacman -S ${PACKAGES[@]}
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.7 - Installing & Configuring GRUB"
    echo -e "${GREEN}COMMAND: grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB${WHITE}"
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    echo -e "${GREEN}COMMAND: sed -i "\""s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/"\"" /etc/default/grub${WHITE}"
    sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/" /etc/default/grub
    echo -e "${GREEN}COMMAND: grub-mkconfig -o /boot/grub/grub.cfg${WHITE}"
    grub-mkconfig -o /boot/grub/grub.cfg
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.8 - Enabling Modules"
    echo -e "${GREEN}COMMAND: systemctl enable bluetooth${WHITE}"
    systemctl enable bluetooth
    echo -e "${GREEN}COMMAND: systemctl enable lightdm${WHITE}"
    systemctl enable lightdm
    echo -e "${GREEN}COMMAND: systemctl enable NetworkManager${WHITE}"
    systemctl enable NetworkManager
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.9 - Adding User"
    CHOICE="y"
    while [ $CHOICE == "y" ]
    do
        read -p "User name: " USER_NAME
        echo -e "${GREEN}COMMAND: useradd -m -g wheel $USER_NAME${WHITE}"
        useradd -m -g wheel $USER_NAME
        echo -e "${GREEN}COMMAND: passwd $USER_NAME${WHITE}"
        passwd $USER_NAME
        echo ""
        read -p "Add another user? [y/n]: " CHOICE
    done
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.10 - Disabling PC Speaker"
    echo -e "${GREEN}COMMAND: echo "\""blacklist pcspkr"\"" > /etc/modprobe.d/nobeep.conf${WHITE}"
    echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.11 - Configuring Bluetooth"
    echo -e "${GREEN}COMMAND: sed -i "\""s/#AutoEnable=false/AutoEnable=true/"\"" /etc/bluetooth/main.conf${WHITE}"
    sed -i "s/#AutoEnable=false/AutoEnable=true/" /etc/bluetooth/main.conf
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.12 - Configuring LightDM"
    echo -e "${GREEN}COMMAND: sed -i "\""s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/"\"" /etc/lightdm/lightdm.conf${WHITE}"
    sed -i "s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/" /etc/lightdm/lightdm.conf
    echo -e "${GREEN}COMMAND: echo -e "\""[greeter]\ntheme-name = Arc-Darker\nicon-theme-name = Papirus\nfont-name = Iosevka Medium 10\nbackground = /usr/share/pixmaps/Wallpaper.jpg\nclock-format = %A, %H:%M"\"" > /etc/lightdm/lightdm-gtk-greeter.conf${WHITE}"
    echo -e "[greeter]\ntheme-name = Arc-Darker\nicon-theme-name = Papirus\nfont-name = Iosevka Medium 10\nbackground = /usr/share/pixmaps/Wallpaper.jpg\nclock-format = %A, %H:%M" > /etc/lightdm/lightdm-gtk-greeter.conf
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.13 - Configuring Sudoers"
    echo -e "${GREEN}COMMAND: sed -i "\""s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/"\"" /etc/sudoers${WHITE}"
    sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
    read -p "Press enter to continue."
    echo ""

    echo "Step 3.14 - Exiting Arch"
    read -p "Exit Arch manually with COMMAND: exit. Press enter to continue."
}

finish_installation () {
    echo "╔═══════════════════════════════════╗"
    echo "║ ▒█▀▀▀ ▀█▀ ▒█▄░▒█ ▀█▀ ▒█▀▀▀█ ▒█░▒█ ║"
    echo "║ ▒█▀▀▀ ▒█░ ▒█▒█▒█ ▒█░ ░▀▀▀▄▄ ▒█▀▀█ ║"
    echo "║ ▒█░░░ ▄█▄ ▒█░░▀█ ▄█▄ ▒█▄▄▄█ ▒█░▒█ ║"
    echo "║           Installation            ║"
    echo "╚═══════════════════════════════════╝"

    echo "Step 4.1 - Removing anarchi.sh from Arch"
    echo -e "${GREEN}COMMAND: rm /mnt/anarchi.sh${WHITE}"
    rm /mnt/anarchi.sh
    read -p "Press enter to continue."
    echo ""

    echo "Step 4.2 - Unmounting Partitions"
    echo -e "${GREEN}COMMAND: umount -R /mnt${WHITE}"
    umount -R /mnt
    echo -e "${GREEN}COMMAND: lsblk${WHITE}"
    lsblk
    read -p "Please make sure the partitions was properly unmounted. Press enter to continue."
    echo ""

    echo "Step 4.3 - Rebooting System"
    read -p "Reboot system manually with COMMAND: reboot, configure boot priority, and boot into Arch. Press enter to continue."
    rm anarchi.sh
}

unknown_choice () {
    echo "ERROR: Unknown choice."
}

main () {
    echo "╔══════════════════════════════════════════╗"
    echo "║ ░█▀▀█ ▒█▄░▒█ ░█▀▀█ ▒█▀▀█ ▒█▀▀█ ▒█░▒█ ▀█▀ ║"
    echo "║ ▒█▄▄█ ▒█▒█▒█ ▒█▄▄█ ▒█▄▄▀ ▒█░░░ ▒█▀▀█ ▒█░ ║"
    echo "║ ▒█░▒█ ▒█░░▀█ ▒█░▒█ ▒█░▒█ ▒█▄▄█ ▒█░▒█ ▄█▄ ║"
    echo "║         An Arch Installer v1.1.3         ║"
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
