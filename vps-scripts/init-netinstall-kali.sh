#!/bin/bash

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

# Set the username
username="viktus"

# Ask the user for the password
echo "Please enter the password for the new user:"
read -s password

# Add the new user
echo "Adding new user \"$username\" with password provided"
adduser --quiet --disabled-password --shell /bin/bash --home /home/$username --gecos "User" $username

# Set the password
echo "$username:$password" | chpasswd

# Add the new user to the sudo group
echo "Adding new user to sudo group..."
usermod -aG sudo $username

# Force password change at next login
echo "Setting up password change at next login..."
passwd --expire $username

# Disable password authentication via SSH
echo "Disabling password authentication via SSH..."
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Copy SSH keys for the new user
echo "Setting up SSH keys for the new user..."
mkdir /home/$username/.ssh
cp /root/.ssh/authorized_keys /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh
chmod 700 /home/$username/.ssh
chmod 600 /home/$username/.ssh/authorized_keys

# Restart SSH service
systemctl restart ssh

# Print the instructions
echo "User has been created and added to the sudo group. On first login, they will be required to change their password."
echo "Password login via SSH has been disabled."

