#!/bin/bash

# Update APT
echo "Updating..."
apt update

# Install base packages
echo "Installing base packages..."
apt install git curl sudo build-essential qterminal zsh cifs-utils ufw fonts-firacode zsh-autosuggestions  

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Ensure the temporary directory was created
if [ ! -d "$TEMP_DIR" ]; then
  echo "Failed to create a temporary directory!"
  exit 1
fi

# Clone the repository into the temporary directory
echo "Cloning the repository to $TEMP_DIR..."
git clone https://github.com/vinceliuice/grub2-themes.git "$TEMP_DIR"

# Check if the repository was cloned successfully
if [ $? -ne 0 ]; then
  echo "Failed to clone the repository!"
  exit 1
fi

# Navigate to the temporary directory
cd "$TEMP_DIR" || exit

# Run the install script
echo "Running the install script..."
bash ./install.sh -t vimix

# Clean up: Remove the temporary directory
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

# Backup the current sources.list
echo "Backing up the current /etc/apt/sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Define the URL for the new sources.list
SOURCES_URL="https://gist.githubusercontent.com/hakerdefo/5e1f51fa93ff37871b9ff738b05ba30f/raw/7b5a0ff76b7f963c52f2b33baa20d8c4033bce4d/sources.list"

# Download the new sources.list
echo "Downloading the new sources.list..."
curl -fsSL "$SOURCES_URL" -o /etc/apt/sources.list

# Check if the download was successful
if [ $? -eq 0 ]; then
  echo "New sources.list downloaded successfully!"
else
  echo "Failed to download the new sources.list. Restoring the backup..."
  cp /etc/apt/sources.list.bak /etc/apt/sources.list
  exit 1
fi

# Update the package lists
echo "Updating package lists..."
apt update

# Confirm completion
if [ $? -eq 0 ]; then
  echo "Package lists updated successfully!"
else
  echo "Failed to update package lists. Please check your sources.list."
fi

echo "Done."


# Add primary user to sudoers file  
# /etc/sudoers "taylor ALL=(ALL:ALL) ALL"

# Download Kali Themes https://gitlab.com/kalilinux/packages/kali-themes.git  
# create .themes and .icons  
# copy kali theme to .themes  
# copy kali icons to .icons

#install build-essential

# setup terminal  
#sudo apt install qterminal zsh  
# download https://gist.githubusercontent.com/noahbliss/4fec4f5fa2d2a2bc857cccc5d00b19b6/raw/db5ceb8b3f54b42f0474105b4a7a138ce97c0b7a/kali-zshrc  
# save to .zshrc in home direcotyr  
#chagne shell chsh -s /bin/zsh  
#sudo apt install zsh-autosuggestions  
#autoload -Uz compinit promptinit  
#compinit  
#promptinit  
#Copy over all the files from your Kali system in the directory /usr/share/qtermwidget5/color-schemes/* to the same location on your Ubuntu system.  
#sudo apt install fonts-firacode
