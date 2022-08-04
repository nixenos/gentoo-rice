echo -e "Synchronising and updating portage"

emerge-webrsync
emerge --sync

echo -e "${Yellow}Select profile${Color_Off}"
eselect profile list
read -p "$(echo -e "Select profile from list above: ")" profile_selection
eselect profile set $profile_selection

echo -e "${BIPurple}Updating @world set${Color_Off}"
emerge --verbose --update --deep --newuse @world

echo -e "Setting timezone to Europe/Warsaw"
echo "Europe/Warsaw" > /etc/timezone
emerge --config sys-libs/timezone-data

echo -e "Setting up locales"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale list
read -p "$(echo -e "Select default locale: ")" locale_selection
eselect locale set $locale_selection

echo -e "${Yellow}Reloading the environment!${Color_Off}"
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo -e "${Green}Setting up kernel${Color_Off}"
emerge sys-kernel/linux-firmware
emerge sys-kernel/gentoo-sources
eselect kernel list
read -p "$(echo -e "Select kernel sources: ")" kernel_selection
eselect kernel set $kernel_selection
emerge sys-kernel/genkernel

echo -e "${BIRed}Generate fstab!${Color_Off}"
echo "${efi_part}   /boot/efi     vfat    defaults    0 0" >> /etc/fstab
echo "${boot_part}   /boot     ext4    noauto,noatime    1 2" >> /etc/fstab
echo "${swap_part}   none     swap    sw    0 0" >> /etc/fstab
echo "${root_part}   /     f2fs    defaults    0 0" >> /etc/fstab

echo -e "Compiling genkernel"
genkernel all
emerge @module-rebuild

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
echo "hostname=\"${hostname}\"" > /etc/conf.d/hostname

echo "127.0.0.1   ${hostname} ${hostname}.localdomain localhost" >> /etc/hosts

echo -e "${Red}Set root password${Color_Off}"
passwd

echo -e "${Blue}Install basic needed tools${Color_Off}"

emerge app-admin/sysklogd
rc-update add sysklogd default
emerge sys-process/cronie
rc-update add cronie default
emerge sys-apps/mlocate
emerge net-misc/chrony
rc-update add chronyd default
emerge sys-fs/f2fs-tools
emerge networkmanager
rc-update add NetworkManager default
emerge zsh

echo -e "${Green}Installing GRUB${Color_Off}"

emerge --verbose sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "Adding user nixen with needed stuff"
groupadd lp
groupadd video
groupadd usb
groupadd users
groupadd lpadmin
groupadd wheel
groupadd audio
useradd -m -s /bin/zsh -G lp,wheel,audio,video,usb,users,lpadmin,nixen nixen
passwd nixen

echo -e"${Red}Bootstrapping needed repository for installing my config"
emerge wget
emerge unzip
cd /root
wget https://github.com/nixenos/gentoo-rice/archive/refs/heads/main.zip
cp main.zip /home/nixen/
chown nixen /home/nixen/main.zip
unzip main.zip
cd gentoo-rice-main/configs
while read package; do
  emerge $package;
done < "installed_packages.txt"

echo "permit persist :wheel" >> /etc/doas.conf
echo "permit nopass nixen cmd reboot" >> /etc/doas.conf
echo "permit nopass nixen cmd poweroff" >> /etc/doas.conf
echo "permit nopass keepenv :wheel as root cmd shutdown args -p now" >> /etc/doas.conf
echo "permit nopass keepenv :wheel as root cmd poweroff" >> /etc/doas.conf
echo "permit nopass keepenv :wheel as root cmd reboot" >> /etc/doas.conf
echo "permit nopass keepenv root as root" >> /etc/doas.conf

echo -e "${Green}Done installing packages! Now login as user nixen, unzip main.zip file and run setup-user-configs.sh script with doas${Color_Off}"
