#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
WHITE="\e[0m"

read -p "Mirror link URL: " MIRROR_LINK_URL
if [[ -z $MIRROR_LINK_URL ]]; then
  echo -e "${RED}[x] Mirror link URL must be provided.${WHITE}"
  exit 1
fi

if [[ ${MIRROR_LINK_URL: -1} == "/" ]]; then
  MIRROR_LINK_URL=${MIRROR_LINK_URL::-1}
fi

echo -e "${GREEN}[i] Downloading ISO file.${WHITE}"
DATE=$(echo $MIRROR_LINK_URL | rev | cut -d "/" -f 1 | rev)
ISO_FILE_NAME=archlinux-$DATE-x86_64.iso
curl -O $MIRROR_LINK_URL/$ISO_FILE_NAME

echo -e "${GREEN}[i] Downloading signatures file.${WHITE}"
ISO_SIGNATURE_FILE_NAME=$ISO_FILE_NAME.sig
curl -O $MIRROR_LINK_URL/$ISO_SIGNATURE_FILE_NAME
curl -O $MIRROR_LINK_URL/b2sums.txt

echo -e "${GREEN}[i] Checking signatures.${WHITE}"
b2sum -c b2sums.txt
read -p "Press enter to continue."
gpg --keyserver-options auto-key-retrieve --verify $ISO_SIGNATURE_FILE_NAME
read -p "Press enter to continue."
pacman-key -v $ISO_SIGNATURE_FILE_NAME
read -p "Press enter to continue."

echo -e "${GREEN}[i] Formatting flash drive.${WHITE}"
read -p "Please insert flash drive first then press enter to continue."
lsblk
read -p "Flash drive block: " FLASH_DRIVE_BLOCK
while [[ -z $FLASH_DRIVE_BLOCK ]]; do
  echo -e "${RED}[x] Flash drive block must be provided.${WHITE}"
  read -p "Flash drive block: " FLASH_DRIVE_BLOCK
done
sudo mkfs.vfat -I $FLASH_DRIVE_BLOCK
lsblk
read -p "Press enter to continue."

echo -e "${GREEN}[i] Making bootable disk.${WHITE}"
sudo dd bs=4M if=$PWD/$ISO_FILE_NAME of=$FLASH_DRIVE_BLOCK conv=fsync oflag=direct status=progress && sync
lsblk
read -p "Press enter to continue."
