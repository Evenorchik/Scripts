#!/bin/bash

# Text Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color (reset)

# Check if curl is installed, and install it if not available
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi

# Function to display success messages
success_message() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Function to display informational messages
info_message() {
    echo -e "${CYAN}[INFO] $1${NC}"
}

# Function to display error messages
error_message() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Function to display warning messages
warning_message() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Function to print the menu using the Node Wizard design
print_menu() {
    echo -e "\n${BOLD}${WHITE}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${NC}"
    echo -e "${BOLD}${WHITE}│      Gensyn Node Wizard             │${NC}"
    echo -e "${BOLD}${WHITE}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${NC}\n"

    echo -e "${BOLD}${BLUE}Available actions:${NC}\n"
    echo -e "${WHITE}[${CYAN}1${WHITE}] ${GREEN}Install Node${NC}"
    echo -e "${WHITE}[${CYAN}2${WHITE}] ${GREEN}Update Node${NC}"
    echo -e "${WHITE}[${CYAN}3${WHITE}] ${GREEN}View Logs${NC}"
    echo -e "${WHITE}[${CYAN}4${WHITE}] ${GREEN}Remove Node${NC}"
    echo -e "${WHITE}[${CYAN}5${WHITE}] ${GREEN}Exit${NC}\n"
}

# Function to display your custom logo using the Node Wizard design
display_logo() {
    clear
    # Display your custom logo using your repository
    curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/refs/heads/main/evenorlogo.sh | bash
}

# Clear the screen and show the logo
clear
display_logo

# Function to install the node
install_node() {
    echo -e "\n${BOLD}${BLUE}Installing Gensyn Node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/5${WHITE}] ${GREEN}Installing basic dependencies...${NC}"
    # Update the system and install basic dependencies
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
    success_message "Basic dependencies installed"
    sleep 1

    echo -e "${WHITE}[${CYAN}2/5${WHITE}] ${GREEN}Installing Docker and Docker Compose...${NC}"
    # Check for Docker installation
    if ! command -v docker &> /dev/null; then
        info_message "Docker is not installed. Installing Docker..."
        sudo apt update
        sudo apt install docker.io -y
        # Enable and start Docker daemon if not running
        sudo systemctl enable --now docker
        success_message "Docker installed successfully"
    else
        success_message "Docker is already installed"
    fi
    
    # Check for Docker Compose installation
    if ! command -v docker-compose &> /dev/null; then
        info_message "Docker Compose is not installed. Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        success_message "Docker Compose installed successfully"
    else
        success_message "Docker Compose is already installed"
    fi

    sudo usermod -aG docker $USER
    success_message "User added to docker group"
    sleep 1

    echo -e "${WHITE}[${CYAN}3/5${WHITE}] ${GREEN}Installing Python and Node.js dependencies...${NC}"
    sudo apt-get install python3 python3-pip python3-venv python3-dev -y
    success_message "Python and dependencies installed"
    sleep 1
    
    sudo apt-get update
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
    node -v
    sudo npm install -g yarn
    yarn -v

    curl -o- -L https://yarnpkg.com/install.sh | bash
    export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
    source ~/.bashrc
    success_message "Node.js and Yarn installed"

    echo -e "${WHITE}[${CYAN}4/5${WHITE}] ${GREEN}Cloning repository...${NC}"
    cd
    git clone https://github.com/gensyn-ai/rl-swarm/
    success_message "Repository cloned successfully"
    sleep 1
    
    echo -e "${WHITE}[${CYAN}5/5${WHITE}] ${GREEN}Finalizing installation...${NC}"
    
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Node installation completed successfully!${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "Follow my X for updates and guide - https://x.com/Evenorchik"
}

# Function to check logs
check_logs() {
    echo -e "\n${BOLD}${BLUE}Viewing Gensyn Node Logs...${NC}\n"
    cd
    screen -r gensyn
}

# Function to remove the node
remove_node() {
    echo -e "\n${BOLD}${RED}Removing Gensyn Node...${NC}\n"
    
    echo -e "${WHITE}[${CYAN}1/2${WHITE}] ${GREEN}Stopping processes...${NC}"
    screen -XS swarm quit
    success_message "Processes stopped"
    
    echo -e "${WHITE}[${CYAN}2/2${WHITE}] ${GREEN}Removing files...${NC}"
    # Remove the directory if it exists
    if [ -d "$HOME/rl-swarm" ]; then
        rm -rf $HOME/rl-swarm
        success_message "Node directory removed"
    else
        warning_message "Node directory not found"
    fi
    
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Gensyn Node removed successfully!${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Main program loop
while true; do
    clear
    # Display the custom logo
    display_logo

    print_menu
    # Use echo -ne so that ANSI escape codes for formatting are interpreted correctly.
    echo -ne "${BOLD}${BLUE}Enter your choice [1-5]: ${NC}"
    read choice

    case $choice in
        1)
            install_node
            ;;
        2)
            echo -e "${GREEN}Your Gensyn Node is up to date!${NC}"
            ;;
        3)
            check_logs
            ;;
        4)
            remove_node
            ;;
        5)
            echo -e "\n${GREEN}Goodbye!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Error: Invalid choice! Please enter a number from 1 to 5.${NC}\n"
            ;;
    esac
    
    if [[ "$choice" != "3" ]]; then
        echo -e "\nPress Enter to return to the menu..."
        read
    fi
done

#Twitter link: https://x.com/Evenorchik
