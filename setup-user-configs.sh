#!/bin/bash

echo "N I X T O O   user setup"

echo "Setup git"
git config --global user.name "Wojciech Janota"
git config --global user.email "wojciech@janota.ovh"

echo "Copying config files"
cp ./configs/picom.conf ~/.config/
cp -r ./configs/newsboat ~/.config/
cp -r ./configs/mpv ~/.config/
cp -r ./configs/ranger ~/.config/

echo "Installing nvchad"
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
mkdir -p ~/.config/nvim/lua/custom
cp -r ./configs/nvim-lua-custom/* ~/.config/nvim/lua/custom/

echo "Copying wallpapers"
mkdir -p ~/Pictures/Wallpapers/
cp ./Wallpapers/* -p ~/Pictures/Wallpapers/

echo "Installing ohmyzsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Copying .zshrc"
cp ./configs/.zshrc ~/

echo "Prepare .local/bin" 
mkdir -p ~/.local/bin
cp ./local-binaries/* ~/.local/bin/

echo "Install doom emacs"
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
~/.emacs.d/bin/doom install
cp ./configs/emacs/* ~/.doom.d/

echo "Copy dwm autostart script"
mkdir ~/.dwm
cp ./configs/autostart.sh ~/.dwm/

echo "Copy X config files"
cp ./configs/.xinitrc ~/.xinitrc

echo "Install nerdfonts"
mkdir -p ~/.install
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git ~/.install/nerd-fonts
~/.install/nerd-fonts/install.sh

echo "Install suckless suite"
git clone https://github.com/nixenos/nixst.git ~/.install/nixst
cd ~/.install/nixst
git checkout new-base
make
doas make install
git clone https://github.com/nixenos/nixdwm.git ~/.install/nixdwm
cd ~/.install/nixdwm
make
doas make install
git clone https://github.com/nixenos/nixdmenu.git ~/.install/nixdmenu
cd ~/.install/nixdmenu
make
doas make install
git clone https://github.com/nixenos/nixdwmblocks.git ~/.install/nixdwmblocks
cd ~/.install/nixdwmblocks/
make
doas make install

echo "Generate SSH key"
ssh-keygen -t ed25519 -C "wojciech@janota.ovh"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

echo "Initialize GPG key"
gpg --full-generate-key

echo "Installing muttwizard"
git clone https://github.com/LukeSmithxyz/mutt-wizard ~/.install/mutt-wizard
cd ~/.install/mutt-wizard/
doas make install

echo "Configuring emails"
mw -a wojciech@janota.ovh -S mail.janota.ovh -s 587 -I mail.janota.ovh -i 993
mw -a wojcjan197@student.polsl.pl -n "Wojciech Janota" -i outlook.office365.com -I 993 -s smtp.office365.com -S 587

echo "All packages installed, all configs are in place!"
