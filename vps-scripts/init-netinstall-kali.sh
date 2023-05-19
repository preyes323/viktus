#!/bin/bash

# Set the username and password
username="viktus"
password="password"

# Ask the user if they want to perform a dist-upgrade
read -p "Do you want to perform a dist-upgrade? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Performing dist-upgrade..."
    apt update && apt dist-upgrade -y
fi

# Install the kali-linux-headless metapackage
echo "Installing kali-linux-headless..."
apt update && apt install -y kali-linux-headless

# Clean up unneeded packages
echo "Cleaning up unnecessary packages..."
apt autoremove -y && apt clean

# Install UFW
echo "Installing UFW..."
apt install -y ufw

# Default policies
echo "Setting up UFW rules..."
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow ssh

# Enable UFW
echo "Enabling UFW..."
ufw --force enable

# Add the new user
echo "Adding new user \"$username\" with default password: \"$password\""
adduser --quiet --disabled-password --shell /bin/bash --home /home/$username --gecos "User" $username

# Set the password
echo "$username:$password" | chpasswd

# Add the new user to the sudo group
echo "Adding new user to sudo group..."
usermod -aG sudo $username

# Force password change at next login
echo "Setting up password change at next login..."
passwd --expire $username

# Print the instructions
echo "User has been created and added to the sudo group. On first login, they will be required to change their password."

