#!/bin/bash

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Function for displaying success messages
success_message() {
    echo -e "${GREEN}[✓] $1${NC}"
}

# Function for displaying information messages
info_message() {
    echo -e "${CYAN}[i] $1${NC}"
}

# Function for displaying errors
error_message() {
    echo -e "${RED}[✗] $1${NC}"
}

# Function for displaying warnings
warning_message() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Function for installing dependencies
install_dependencies() {
    info_message "Installing necessary packages..."
    sudo apt update && sudo apt-get upgrade -y
    sudo apt install -y git make jq build-essential gcc unzip wget lz4 aria2 curl
    success_message "Dependencies installed"
}

# Check for curl and install if not present
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi

# Clear screen
clear

# Display logo
curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/refs/heads/main/evenorlogo.sh | bash

# Function for displaying menu
print_menu() {
    echo -e "\n${BOLD}${WHITE}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${NC}"
    echo -e "${BOLD}${WHITE}│        🔷 Hi, im dria wizzard!        │${NC}"
    echo -e "${BOLD}${WHITE}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${NC}\n"
    
    echo -e "${BOLD}${BLUE}⚒️ Available actions:${NC}\n"
    echo -e "${WHITE}[${CYAN}1${WHITE}] ${GREEN}➜ ${WHITE}⚙️  Install node${NC}"
    echo -e "${WHITE}[${CYAN}2${WHITE}] ${GREEN}➜ ${WHITE}▶️  Start node${NC}"
    echo -e "${WHITE}[${CYAN}3${WHITE}] ${GREEN}➜ ${WHITE}📈  Update node${NC}"
    echo -e "${WHITE}[${CYAN}4${WHITE}] ${GREEN}➜ ${WHITE}🔧 Change port${NC}"
    echo -e "${WHITE}[${CYAN}5${WHITE}] ${GREEN}➜ ${WHITE}📊 Check logs${NC}"
    echo -e "${WHITE}[${CYAN}6${WHITE}] ${GREEN}➜ ${WHITE}♻️  Remove node${NC}"
    echo -e "${WHITE}[${CYAN}7${WHITE}] ${GREEN}➜ ${WHITE}🚶 Exit${NC}\n"
}

# Function for installing the node
install_node() {
    echo -e "\n${BOLD}${BLUE}⚡ Installing Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}⚒️ Installing dependencies...${NC}"
    install_dependencies

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading installer...${NC}"
    info_message "Downloading and installing Dria Compute Node..."
    curl -fsSL https://dria.co/launcher | bash
    success_message "Installer downloaded and executed"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🔄 Starting node...${NC}"
    dkn-compute-launcher start

    echo -e "\n${PURPLE}═════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Node successfully installed and started!${NC}"
    echo -e "${PURPLE}═════════════════════════════════════════════${NC}\n"
}

# Function to start node as a service
start_node_service() {
    echo -e "\n${BOLD}${BLUE}🔄 Starting Dria node as a service...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Creating service file...${NC}"
    # Define current user name and home directory
    USERNAME=$(whoami)
    HOME_DIR=$(eval echo ~$USERNAME)

    # Create service file
    sudo bash -c "cat <<EOT > /etc/systemd/system/dria.service
[Unit]
Description=Dria Compute Node Service
After=network.target

[Service]
User=$USERNAME
EnvironmentFile=$HOME_DIR/.dria/dkn-compute-launcher/.env
ExecStart=/usr/local/bin/dkn-compute-launcher start
WorkingDirectory=$HOME_DIR/.dria/dkn-compute-launcher/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT"
    success_message "Service file created"

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}🔄 Configuring system services...${NC}"
    # Reload and start service
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-journald
    sleep 1
    sudo systemctl enable dria
    sudo systemctl start dria
    success_message "Service configured and started"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}📊 Checking logs...${NC}"
    echo -e "\n${PURPLE}═════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📝 Command to check logs:${NC}"
    echo -e "${CYAN}sudo journalctl -u dria -f --no-hostname -o cat${NC}"
    echo -e "${PURPLE}═════════════════════════════════════════════${NC}\n"

    # Check logs
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Function for updating the node
update_node() {
    echo -e "\n${BOLD}${GREEN}✓ You have the latest version of Dria node installed${NC}\n"
}

# Function for changing the port
change_port() {
    echo -e "\n${BOLD}${BLUE}🔧 Changing Dria node port...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}⏹️ Stopping service...${NC}"
    sudo systemctl stop dria
    success_message "Service stopped"

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Configuring new port...${NC}"
    # Ask user for new port
    echo -e "${YELLOW}🔢 Enter new port for Dria:${NC}"
    read -p "➜ " NEW_PORT

    # Path to .env file
    ENV_FILE="$HOME/.dria/dkn-compute-launcher/.env"

    # Update port in .env file
    sed -i "s|DKN_P2P_LISTEN_ADDR=/ip4/0.0.0.0/tcp/[0-9]*|DKN_P2P_LISTEN_ADDR=/ip4/0.0.0.0/tcp/$NEW_PORT|" "$ENV_FILE"
    success_message "Port changed to $NEW_PORT"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🔄 Restarting service...${NC}"
    # Restart service
    sudo systemctl daemon-reload
    sudo systemctl restart systemd-journald
    sudo systemctl start dria
    success_message "Service restarted with new port"

    echo -e "\n${PURPLE}═════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📝 Command to check logs:${NC}"
    echo -e "${CYAN}sudo journalctl -u dria -f --no-hostname -o cat${NC}"
    echo -e "${PURPLE}═════════════════════════════════════════════${NC}\n"

    # Check logs
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Function for checking logs
check_logs() {
    echo -e "\n${BOLD}${BLUE}📊 Checking Dria node logs...${NC}\n"
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Function for removing the node
remove_node() {
    echo -e "\n${BOLD}${RED}⚠️ Removing Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/2${WHITE}] ${GREEN}➜ ${WHITE}⏹️ Stopping services...${NC}"
    # Stop and remove service
    sudo systemctl stop dria
    sudo systemctl disable dria
    sudo rm /etc/systemd/system/dria.service
    sudo systemctl daemon-reload
    sleep 2
    success_message "Services stopped and removed"

    echo -e "${WHITE}[${CYAN}2/2${WHITE}] ${GREEN}➜ ${WHITE}♻️ Removing files...${NC}"
    # Remove node folder
    rm -rf $HOME/.dria
    rm -rf ~/dkn-compute-node
    success_message "Node files removed"

    echo -e "\n${GREEN}✓ Dria node successfully removed!${NC}\n"
    sleep 2
}

# Main program loop
while true; do
    clear
    # Display logo
    curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/refs/heads/main/evenorlogo.sh | bash
    
    print_menu
    echo -e "${BOLD}${BLUE}📝 Enter action number [1-7]:${NC} "
    read -p "➜ " choice

    case $choice in
        1)
            install_node
            ;;
        2)
            start_node_service
            ;;
        3)
            update_node
            ;;
        4)
            change_port
            ;;
        5)
            check_logs
            ;;
        6)
            remove_node
            ;;
        7)
            echo -e "\n${GREEN}👋 Goodbye!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}✗ Error: Invalid choice! Please enter a number from 1 to 7.${NC}\n"
            ;;
    esac
    
    if [ "$choice" != "2" ] && [ "$choice" != "4" ] && [ "$choice" != "5" ]; then
        echo -e "\nPress Enter to return to menu..."
        read
    fi
done
