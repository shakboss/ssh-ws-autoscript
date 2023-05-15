#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'


echo -e "${CYAN}=============================${RESET}"
echo -e "${MAGENTA}Script By: LalanthaM${RESET}"
echo -e "${MAGENTA}More Info: lalantha.com${RESET}"
echo -e "${CYAN}=============================${RESET}"

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Prerequisites: ${RESET}"
echo -e "${YELLOW}Please follow the instrctions given in this link before you continue with the script.${RESET}"
echo -e "${YELLOW}Link: https://notes.lalantha.com/s/-NFhBCUHE${RESET}"
echo -e "${YELLOW}You can stop the script execution by running CTRL+C and perform the instructions.${RESET}"
echo -e "${YELLOW}When you are done with the prerequisites run script again and press ENTER to continue${RESET}"
echo -e "${CYAN}=============================${RESET}"

echo -e "${GREEN}Press Enter to continue...${RESET}"

# Wait for user input
read

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Running Privilege Check${RESET}"
echo -e "${CYAN}=============================${RESET}"
# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root.${RESET}"
    exit 1
fi

# Continue with the rest of the script as root
echo -e "${GREEN}Running as root. Performing privileged operations...${RESET}"


# Update Server
echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Updating Server${RESET}"
echo -e "${CYAN}=============================${RESET}"
apt update
apt upgrade -y


# Install Required Tools
echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Installing Required Tools${RESET}"
echo -e "${CYAN}=============================${RESET}"
apt install dropbear squid stunnel cmake make gcc build-essential nodejs unzip zip tmux -y

# Configure Dropbear
echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Configuring Dropbear${RESET}"
echo -e "${CYAN}=============================${RESET}"

# Config Options Values
dropbear_config="/etc/default/dropbear"
option_dStart="NO_START"
value_dStart="0"
option_dPort="DROPBEAR_PORT"
value_dPort="40000"
option_dBanner="DROPBEAR_BANNER"
value_dBanner="/etc/banner.dat"

# Add Banner
banner_file="/etc/banner.dat"

# Content to add to the banner file
content="<b><font color=\"#2E86C1\">===============================</font>\n<h4>&#9734; <font color=\"#FF6347\">Premium SSH Server</font> &#9734;</h4>\n<b><font color=\"#D35400\">LalanthaM &trade;</font> Auto Script</b><br>\n<b>Server By: <font color=\"#138D75\">Lalantha Madhushan</font></b><br>\n<b>For More Info: <font color=\"#2E86C1\">lalantha.com</font></b>\n<br></b>\n</br><b><font color=\"#2E86C1\">===============================</font></b><br>"

# Write the content to the banner file
echo -e "$content" | sudo tee "$banner_file" > /dev/null

echo "Content added to $banner_file"

# Use sed to find and replace the options in the config file
sed -i "s/\($option_dStart *= *\).*/\1$value_dStart/" "$dropbear_config"
echo -e "${GREEN}Changed No Start to 0${RESET}"
sed -i "s/\($option_dPort *= *\).*/\1$value_dPort/" "$dropbear_config"
echo -e "${GREEN}Changed Port to 4000${RESET}"
sed -i "s#\($option_dBanner *= *\).*#\1\"$value_dBanner\"#" "$dropbear_config"
echo -e "${GREEN}Changed Banner Path to '/etc/banner.dat'. Replace Your Own Banner There.${RESET}"

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Installing UDPGW (Game/UDP support)${RESET}"
echo -e "${CYAN}=============================${RESET}"
wget https://github.com/ambrop72/badvpn/archive/master.zip
unzip master.zip
cd badvpn-master
mkdir build
cd build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
sudo make install
cd $HOME

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Installing Proxy Javascript${RESET}"
echo -e "${CYAN}=============================${RESET}"
cd /etc/systemd/system
wget https://gitlab.com/PANCHO7532/scripts-and-random-code/-/raw/master/nfree/nodews1.service
cd /etc
mkdir p7common
cd p7common
wget https://gitlab.com/PANCHO7532/scripts-and-random-code/-/raw/master/nfree/proxy3.js
systemctl enable nodews1
systemctl start nodews1
systemctl status nodews1 --no-pager
echo -e "${GREEN}Proxy Javascript Installed${RESET}"

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Configuring Stunnel${RESET}"
echo -e "${CYAN}=============================${RESET}"
cd /etc/stunnel
wget https://gitlab.com/PANCHO7532/scripts-and-random-code/-/raw/master/nfree/stunnel.conf
echo -e "${YELLOW}Enter the Certificate File Link: ${RESET}"
read link
wget -O certificate.zip "$link"
unzip certificate.zip
#cat private.key certificate.crt ca_bundle.crt > stunnel.pem
cat private.key certificate.crt ca_bundle.crt | sed 's/END RSA PRIVATE KEY-----/END RSA PRIVATE KEY-----\n/' > stunnel.pem
chmod 400 stunnel.pem
systemctl enable stunnel4
systemctl start stunnel4
systemctl status stunnel4 --no-pager


echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Starting UDPGW${RESET}"
echo -e "${CYAN}=============================${RESET}"
cd /etc/systemd/system
wget https://gitlab.com/PANCHO7532/scripts-and-random-code/-/raw/master/nfree/badvpn.service
cd $HOME
systemctl enable badvpn
systemctl start badvpn
systemctl status badvpn --no-pager

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Adding Following Options${RESET}"
echo -e "${CYAN}=============================${RESET}"
echo "/bin/false" | sudo tee -a /etc/shells
echo "/usr/sbin/nologin" | sudo tee -a /etc/shells


echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Create Users (You Need to Do This Manually): ${RESET}"
echo -e "${YELLOW}Setup Users using following commands: ${RESET}"
echo -e "${YELLOW}useradd -M [User Name] -s /bin/false${RESET}"
echo -e "${YELLOW}passwd [User Name]${RESET}"

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Server Reboot is Required${RESET}"
echo -e "${CYAN}=============================${RESET}"

# Prompt the user to confirm reboot
read -p "Press Enter to reboot the server..."

# Reboot the server
reboot

