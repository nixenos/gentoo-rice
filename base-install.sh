#!/bin/bash

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

echo -e "${Green}Basic gentoo setup script for nixtoo installation!${Color_Off}"
echo -e "${BIRed}Execute after partitioning!"
echo -e "Refer to gentoo handbook for guidelines!${Color_Off}"

efi_part=$1
boot_part=$2
swap_part=$3
root_part=$4

echo -e "EFI partition: ${efi_part}"
echo -e "BOOT partition: ${boot_part}"
echo -e "SWAP partition: ${swap_part}"
echo -e "ROOT partition: ${root_part}"

read -p "$(echo -e "${BIRed}Confirm [y/N]: ${Color_Off}")" confirmation

if [[ $confirmation = "y" || $confirmation = "Y" ]]; then
  echo -e "${Green}Partition scheme updated!${Color_Off}"
else
  echo "Exitting..."
  exit
fi

echo -e "${Blue}Formatting partitions without EFI partition${Color_Off}"

echo -e "Formatting BOOT partition to EXT4 journaled"
# mkfs.ext4 -j $boot_part
echo -e "Formatting SWAP"
# mkswap $swap_part
echo -e "Formatting ROOT partition to F2FS"
# mkfs.f2fs -f $root_part

read -p "$(echo -e "${BIRed}Format EFI partition to FAT32? This CANNOT BE UNDONE [y/N]: ${Color_Off}")" format_efi

if [[ $format_efi = "y" || $format_efi = "Y" ]]; then
  echo -e "${BIRed}Formatting EFI as FAT32!${Color_Off}"
  # mkfs.fat -F32 ${efi_part}
else
  echo -e "${Blue}Not formatting EFI${Color_Off}"
fi

echo -e "Mounting new partitions"
# mkdir -p /mnt/gentoo
# mount $root_part /mnt/gentoo
# mkdir -p /mnt/gentoo/boot
# mount $boot_part /mnt/gentoo/boot
# mkdir -p /mnt/gentoo/boot/efi
# mount $efi_part /mnt/gentoo/boot/efi
# swapon $swap_part

echo -e "${Green}Mounted!${Color_Off}"

echo -e "Syncing time with NTP server"
# ntpd -q -g

echo -e "Downloading latest gentoo stage3 tarball"
# wget -r --no-parent -nd -A 'stage3-amd64-desktop-openrc-*.tar.xz' http://ftp.vectranet.pl/gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/
# mv stage3-amd64-desktop-openrc-*.tar.xz stage3-amd64.tar.xz
# cp stage3-amd64.tar.xz /mnt/gentoo/

echo -e "Preparing make.conf"
echo "Supported CFLAGS: "
supported_cflags_temp="$(gcc -march=native -E -v - </dev/null 2>&1 | grep cc1 | grep -o -- '-.*' | cut -d\  -f2- | sed 's/-E / /g' | sed 's/-quiet //g' | sed 's/ -v / /g' )"
supported_cflags="$(echo "${supported_cflags_temp} " | sed 's/ - //g' | sed 's/-param /-param=/g' | sed -r 's/ -mno-\w+-*\w+//g')"
echo $supported_cflags
cp ./configs/make.conf.template make.conf
echo "COMMON_FLAGS=\"${supported_cflags}\"" >> make.conf

cpu_flags_x86=$(cpuid2cpuflags | sed 's/CPU_FLAGS_X86: //g')
echo "CPU_FLAGS_X86=\"${cpu_flags_x86}\"" >> make.conf

cores_count=$(nproc --all)
echo "MAKEOPTS=\"-j${cores_count-1}\"" >> make.conf

read -p "$(echo -e "${BIGreen}Device type[T420/HUAWEI/PC (def: T420)]: ${Color_Off}")" device_selection

if [[ $device_selection = "PC" ]]; then
  echo "VIDEO_CARDS=\"amdgpu radeonsi\"" >> make.conf
elif [[ $device_selection = "HUAWEI" ]]; then
  echo "VIDEO_CARDS=\"intel\"" >> make.conf
else 
  echo "VIDEO_CARDS=\"intel i965\"" >> make.conf
fi

echo "# vim:syntax=sh filetype=sh" >> make.conf

echo -e "${Blue}make.conf ready! Please inspect manually, before emerging world${Color_Off}"

# cp make.conf /mnt/gentoo/etc/portage/
# mkdir /mnt/gentoo/etc/portage/package.use
# cp ./configs/package.use/* /mnt/gentoo/etc/portage/package.use/

echo -e "Changing operating directory to /mnt/gentoo, unpacking stage3 tarball"
# cd /mnt/gentoo/
# tar xpvf stage3-amd64.tar.xz --xattrs-include='*.*' --numeric-owner

echo -e "Copy DNS info to new system"
# cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

echo -e "${BIYellow}Mounting needed pseudo filesystems to new system${Color_Off}"
# mount --types proc /proc /mnt/gentoo/proc
# mount --rbind /sys /mnt/gentoo/sys
# mount --make-rslave /mnt/gentoo/sys
# mount --rbind /dev /mnt/gentoo/dev
# mount --make-rslave /mnt/gentoo/dev
# mount --bind /run /mnt/gentoo/run
# mount --make-slave /mnt/gentoo/run

echo -e "${BIRed}CHROOTING INTO NEW SYSTEM!${Color_Off}"
# chroot /mnt/gentoo /bin/bash
# source /etc/profile
# export PS1="(chroot) ${PS1}"

echo -e "Synchronising and updating portage"

# emerge-webrsync
# emerge --sync

echo -e "${Yellow}Select profile${Color_Off}"
# eselect profile list
read -p "$(echo -e "Select profile from list above: ")" profile_selection
# eselect profile set $profile_selection

echo -e "${BIPurple}Updating @world set${Color_Off}"
# emerge --verbose --update --deep --newuse @world

echo -e "Setting timezone to Europe/Warsaw"
# echo "Europe/Warsaw" > /etc/timezone
# emerge --config sys-libs/timezone-data

echo -e "Setting up locales"
# echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
# echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
# echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
# locale-gen
# eselect locale list
read -p "$(echo -e "Select default locale: ")" locale_selection
# eselect locale set $locale_selection

echo -e "${Yellow}Reloading the environment!${Color_Off}"
# env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo -e "${Green}Setting up kernel${Color_Off}"
# emerge sys-kernel/linux-firmware
# emerge sys-kernel/gentoo-sources
# eselect kernel list
read -p "$(echo -e "Select kernel sources: ")" kernel_selection
# eselect kernel set $kernel_selection
# emerge sys-kernel/genkernel

echo -e "${BIRed}Generate fstab!${Color_Off}"
# echo "${efi_part}   /boot/efi     vfat    defaults    0 0" >> /etc/fstab
# echo "${boot_part}   /boot     ext4    noauto,noatime    1 2" >> /etc/fstab
# echo "${swap_part}   none     swap    sw    0 0" >> /etc/fstab
# echo "${root_part}   /     f2fs    defaults    0 0" >> /etc/fstab

echo -e "Compiling genkernel"
# genkernel all
# emerge @module-rebuild

hostname="gentoo-machine"

if [[ $device_selection = "HUAWEI" ]]; then
  $hostname="gabriel"
elif [[ $device_selection = "PC" ]]; then
  $hostname="ramiel"
elif [[ $device_selection = "T420" ]]; then
  $hostname="metatron"
else
  $hostname="gentoo-machine"
fi
# echo "hostname=\"${hostname}\"" > /etc/conf.d/hostname

# echo "127.0.0.1   ${hostname} ${hostname}.localdomain localhost" >> /etc/hosts

echo -e "${Red}Set root password${Color_Off}"
# passwd

echo -e "${Blue}Install basic needed tools${Color_Off}"

# emerge app-admin/sysklogd
# rc-update add sysklogd default
# emerge sys-process/cronie
# rc-update add cronie default
# emerge sys-apps/mlocate
# emerge net-misc/chrony
# rc-update add chronyd default
# emerge sys-fs/f2fs-tools
# emerge networkmanager
# rc-update add NetworkManager default
# emerge zsh

echo -e "${Green}Installing GRUB${Color_Off}"

# emerge --verbose sys-boot/grub
# grub-install --target=x86_64-efi --efi-directory=/boot/efi
# grub-mkconfig -o /boot/grub/grub.cfg

echo -e "Adding user nixen with needed stuff"
# groupadd lp
# groupadd video
# groupadd usb
# groupadd users
# groupadd lpadmin
# groupadd wheel
# groupadd audio
# useradd -m -s /bin/zsh -G lp,wheel,audio,video,usb,users,lpadmin,nixen nixen
# passwd nixen

echo -e"${Red}Bootstrapping needed repository for installing my config"
# emerge wget
# emerge unzip
# cd /root
# wget https://github.com/nixenos/gentoo-rice/archive/refs/heads/main.zip
# cp main.zip /home/nixen/
# chown nixen /home/nixen/main.zip
# unzip main.zip
# cd gentoo-rice-main/configs
while read package; do
#   emerge $package;
done < "installed_packages.txt"

# echo "permit persist :wheel" >> /etc/doas.conf
# echo "permit nopass nixen cmd reboot" >> /etc/doas.conf
# echo "permit nopass nixen cmd poweroff" >> /etc/doas.conf
# echo "permit nopass keepenv :wheel as root cmd shutdown args -p now" >> /etc/doas.conf
# echo "permit nopass keepenv :wheel as root cmd poweroff" >> /etc/doas.conf
# echo "permit nopass keepenv :wheel as root cmd reboot" >> /etc/doas.conf
# echo "permit nopass keepenv root as root" >> /etc/doas.conf

echo -e "${Green}Done installing packages! Now login as user nixen, unzip main.zip file and run setup-user-configs.sh script with doas${Color_Off}"
