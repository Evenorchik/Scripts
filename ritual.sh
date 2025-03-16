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

# Check for curl availability and install if not installed
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi

# Display logo
clear
curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/refs/heads/main/evenorlogo.sh | bash

# Function to display menu
print_menu() {
    echo -e "\n${BOLD}${WHITE}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${NC}"
    echo -e "${BOLD}${WHITE}│        🚀 WELCOME, RITUALIST!          │${NC}"
    echo -e "${BOLD}${WHITE}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${NC}\n"
    
    echo -e "${BOLD}${BLUE}🛠️ Available actions:${NC}\n"
    echo -e "${WHITE}[${CYAN}1${WHITE}] ${GREEN}➜ ${WHITE}⚙️  Install basic components${NC}"
    echo -e "${WHITE}[${CYAN}2${WHITE}] ${GREEN}➜ ${WHITE}🔧 Configure settings${NC}"
    echo -e "${WHITE}[${CYAN}3${WHITE}] ${GREEN}➜ ${WHITE}✅ Complete installation${NC}"
    echo -e "${WHITE}[${CYAN}4${WHITE}] ${GREEN}➜ ${WHITE}🔄 Restart node${NC}"
    echo -e "${WHITE}[${CYAN}5${WHITE}] ${GREEN}➜ ${WHITE}👛 Change wallet address${NC}"
    echo -e "${WHITE}[${CYAN}6${WHITE}] ${GREEN}➜ ${WHITE}🌐 Change RPC address${NC}"
    echo -e "${WHITE}[${CYAN}7${WHITE}] ${GREEN}➜ ${WHITE}📈 Update node${NC}"
    echo -e "${WHITE}[${CYAN}8${WHITE}] ${GREEN}➜ ${WHITE}❌ Uninstall node${NC}"
    echo -e "${WHITE}[${CYAN}9${WHITE}] ${GREEN}➜ ${WHITE}📊 Check node status${NC}"
    echo -e "${WHITE}[${CYAN}10${WHITE}] ${GREEN}➜ ${WHITE}🚪 Exit${NC}\n"
}

# Function to install basic components
install_ritual() {
    echo -e "\n${BOLD}${BLUE}⚡ Installing basic components...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/4${WHITE}] ${GREEN}➜ ${WHITE}🔄 Updating system...${NC}"
    sudo apt update && sudo apt upgrade -y
    sudo apt autoremove -y

    echo -e "${WHITE}[${CYAN}2/4${WHITE}] ${GREEN}➜ ${WHITE}📦 Installing required packages...${NC}"
    sudo apt -qy install curl git jq lz4 build-essential screen

    echo -e "${WHITE}[${CYAN}3/4${WHITE}] ${GREEN}➜ ${WHITE}🐳 Installing Docker...${NC}"
    if ! command -v docker &> /dev/null; then
        sudo apt install docker.io -y
    fi

    echo -e "${WHITE}[${CYAN}4/4${WHITE}] ${GREEN}➜ ${WHITE}🔧 Installing Docker Compose...${NC}"
    if ! command -v docker-compose &> /dev/null; then
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    # Install Docker Compose CLI plugin
    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

    echo -e "\n${GREEN}✅ Basic components successfully installed!${NC}\n"
    
    # Clone repository
    echo -e "${WHITE}[${CYAN}+${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading Ritual...${NC}"
    git clone https://github.com/ritual-net/infernet-container-starter

    # Configure Docker version
    docker_yaml=~/infernet-container-starter/deploy/docker-compose.yaml
    sed -i 's/image: ritualnetwork\/infernet-node:1.3.1/image: ritualnetwork\/infernet-node:1.2.0/' "$docker_yaml"

    echo -e "\n${GREEN}✨ Installation completed! Starting container...${NC}"
    
    # Check for existing screen session
    if screen -ls | grep -q "ritual"; then
        echo -e "${YELLOW}⚠️ Session ritual already exists. Reconnecting...${NC}"
        screen -r ritual
    else
        # Create a new screen session with the right parameters
        screen -dmS ritual bash
        # Send command to the session
        screen -S ritual -X stuff "cd ~/infernet-container-starter && project=hello-world make deploy-container$(printf \\r)"
        
        echo -e "${YELLOW}⚡ Screen session 'ritual' created and container started${NC}"
        echo -e "${CYAN}To view logs use: screen -r ritual${NC}"
        echo -e "${CYAN}To exit logs use: CTRL + A + D${NC}"
        echo -e "${CYAN}To view session list use: screen -ls${NC}"
        
        # Give time for container to start
        sleep 2
        # Connect to the session
        screen -r ritual
    fi
}

# Function to configure settings
install_ritual_2() {
    echo -e "\n${BOLD}${BLUE}⚡ Configuring node settings...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}🌐 RPC setup...${NC}"
    echo -ne "${BOLD}${YELLOW}Enter RPC URL: ${NC}"
    read -e rpc_url1

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}🔑 Wallet setup...${NC}"
    echo -ne "${BOLD}${YELLOW}Enter Private Key (with or without 0x): ${NC}"
    read -e private_key1
    
    # Add 0x if it's missing
    if [[ ! $private_key1 =~ ^0x ]]; then
        private_key1="0x$private_key1"
    fi

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Applying settings...${NC}"
    
    # Update configuration files
    json_1=~/infernet-container-starter/deploy/config.json
    json_2=~/infernet-container-starter/projects/hello-world/container/config.json
    
    # Create temporary file
    temp_file=$(mktemp)

    # Update configuration
    jq --arg rpc "$rpc_url1" --arg priv "$private_key1" \
        '.chain.rpc_url = $rpc |
         .chain.wallet.private_key = $priv |
         .chain.trail_head_blocks = 3 |
         .chain.registry_address = "0x3B1554f346DFe5c482Bb4BA31b880c1C18412170" |
         .chain.snapshot_sync.sleep = 3 |
         .chain.snapshot_sync.batch_size = 9500 |
         .chain.snapshot_sync.starting_sub_id = 200000 |
         .chain.snapshot_sync.sync_period = 30' $json_1 > $temp_file

    mv $temp_file $json_1

    jq --arg rpc "$rpc_url1" --arg priv "$private_key1" \
        '.chain.rpc_url = $rpc |
         .chain.wallet.private_key = $priv |
         .chain.trail_head_blocks = 3 |
         .chain.registry_address = "0x3B1554f346DFe5c482Bb4BA31b880c1C18412170" |
         .chain.snapshot_sync.sleep = 3 |
         .chain.snapshot_sync.batch_size = 9500 |
         .chain.snapshot_sync.starting_sub_id = 200000 |
         .chain.snapshot_sync.sync_period = 30' $json_2 > $temp_file

    mv $temp_file $json_2

    # Update Makefile
    makefile=~/infernet-container-starter/projects/hello-world/contracts/Makefile 
    sed -i "s|sender := .*|sender := $private_key1|" "$makefile"
    sed -i "s|RPC_URL := .*|RPC_URL := $rpc_url1|" "$makefile"

    # Update Docker version
    docker_yaml=~/infernet-container-starter/deploy/docker-compose.yaml
    sed -i 's/image: ritualnetwork\/infernet-node:1.2.0/image: ritualnetwork\/infernet-node:1.4.0/' "$docker_yaml"

    echo -e "\n${GREEN}✅ Configuration successfully updated!${NC}"
    
    # Automatically start docker compose
    echo -e "\n${YELLOW}🚀 Starting docker compose...${NC}"
    cd ~/infernet-container-starter/deploy && docker compose up -d
    
    echo -e "\n${GREEN}✨ Services started in background mode!${NC}"
    echo -e "${CYAN}To view logs use: docker compose logs -f${NC}"
}

# Function to complete installation
install_ritual_3() {
    echo -e "\n${BOLD}${BLUE}⚡ Completing node installation...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/4${WHITE}] ${GREEN}➜ ${WHITE}🔧 Installing Foundry...${NC}"
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup

    echo -e "${WHITE}[${CYAN}2/4${WHITE}] ${GREEN}➜ ${WHITE}📦 Installing dependencies...${NC}"
    cd ~/infernet-container-starter/projects/hello-world/contracts
    rm -rf lib
    forge install --no-commit foundry-rs/forge-std
    forge install --no-commit ritual-net/infernet-sdk

    echo -e "${WHITE}[${CYAN}3/4${WHITE}] ${GREEN}➜ ${WHITE}📝 Deploying contracts...${NC}"
    cd ~/infernet-container-starter
    project=hello-world make deploy-contracts

    echo -e "${WHITE}[${CYAN}4/4${WHITE}] ${GREEN}➜ ${WHITE}✍️ Configuring contract...${NC}"
    echo -e "${YELLOW}Check the logs above and find the deployed Sayshello address${NC}"
    echo -ne "${CYAN}Enter Sayshello address: ${NC}"
    read -e says_gm

    # Update CallContract.s.sol
    callcontractpath="$HOME/infernet-container-starter/projects/hello-world/contracts/script/CallContract.s.sol"
    sed -i "s|SaysGM saysGm = SaysGM(.*)|SaysGM saysGm = SaysGM($says_gm)|" "$callcontractpath"

    echo -e "\n${GREEN}🚀 Executing final commands...${NC}"
    project=hello-world make call-contract

    echo -e "\n${GREEN}✨ Node installation successfully completed!${NC}"
    echo -e "${CYAN}Visit https://x.com/Evenorchik for updates and support${NC}"
}

# Function to restart node
restart_ritual() {
    echo -e "\n${BOLD}${BLUE}🔄 Restarting node...${NC}\n"
    
    echo -e "${WHITE}[${CYAN}1/2${WHITE}] ${GREEN}➜ ${WHITE}⏹️ Stopping services...${NC}"
    cd ~/infernet-container-starter/deploy
    docker compose down
    
    echo -e "${WHITE}[${CYAN}2/2${WHITE}] ${GREEN}➜ ${WHITE}▶️ Starting services...${NC}"
    echo -e "\n${GREEN}✅ Execute the command:${NC}"
    echo -e "${CYAN}cd ~/infernet-container-starter/deploy && docker compose up${NC}"
    echo -e "${CYAN}For updates and support visit: https://x.com/Evenorchik${NC}"
}

# Function to change wallet address
change_Wallet_Address() {
    echo -e "\n${BOLD}${BLUE}👛 Changing wallet address...${NC}\n"
    
    echo -ne "${BOLD}${YELLOW}Enter new Private Key (with or without 0x): ${NC}"
    read -e private_key1
    
    # Add 0x if it's missing
    if [[ ! $private_key1 =~ ^0x ]]; then
        private_key1="0x$private_key1"
    fi

    # Update configuration files
    json_1=~/infernet-container-starter/deploy/config.json
    json_2=~/infernet-container-starter/projects/hello-world/container/config.json
    makefile=~/infernet-container-starter/projects/hello-world/contracts/Makefile

    temp_file=$(mktemp)

    jq --arg priv "$private_key1" \
        '.chain.wallet.private_key = $priv' $json_1 > $temp_file
    mv $temp_file $json_1

    jq --arg priv "$private_key1" \
        '.chain.wallet.private_key = $priv' $json_2 > $temp_file
    mv $temp_file $json_2

    sed -i "s|sender := .*|sender := $private_key1|" "$makefile"

    echo -e "\n${GREEN}✅ Wallet address successfully updated!${NC}"
    
    echo -e "\n${YELLOW}🔄 Reinstalling contracts...${NC}"
    cd ~/infernet-container-starter
    project=hello-world make deploy-contracts

    echo -e "\n${YELLOW}Check the logs above and find the deployed Sayshello address${NC}"
    echo -ne "${CYAN}Enter Sayshello address: ${NC}"
    read -e says_gm

    callcontractpath="$HOME/infernet-container-starter/projects/hello-world/contracts/script/CallContract.s.sol"
    sed -i "s|SaysGM saysGm = SaysGM(.*)|SaysGM saysGm = SaysGM($says_gm)|" "$callcontractpath"

    project=hello-world make call-contract
    echo -e "${CYAN}Visit https://x.com/Evenorchik for updates and support${NC}"
}

# Function to change RPC address
change_RPC_Address() {
    echo -e "\n${BOLD}${BLUE}🌐 Changing RPC address...${NC}\n"
    
    echo -ne "${BOLD}${YELLOW}Enter new RPC URL: ${NC}"
    read -e rpc_url1

    json_1=~/infernet-container-starter/deploy/config.json
    json_2=~/infernet-container-starter/projects/hello-world/container/config.json
    makefile=~/infernet-container-starter/projects/hello-world/contracts/Makefile

    temp_file=$(mktemp)

    jq --arg rpc "$rpc_url1" \
        '.chain.rpc_url = $rpc' $json_1 > $temp_file
    mv $temp_file $json_1

    jq --arg rpc "$rpc_url1" \
        '.chain.rpc_url = $rpc' $json_2 > $temp_file
    mv $temp_file $json_2

    sed -i "s|RPC_URL := .*|RPC_URL := $rpc_url1|" "$makefile"

    echo -e "\n${GREEN}✅ RPC address successfully updated!${NC}"
    
    echo -e "\n${YELLOW}🔄 Restarting containers...${NC}"
    docker restart infernet-anvil
    docker restart hello-world
    docker restart infernet-node
    docker restart infernet-fluentbit
    docker restart infernet-redis

    echo -e "\n${GREEN}✨ All services restarted!${NC}"
    echo -e "${CYAN}Visit https://x.com/Evenorchik for updates and support${NC}"
}

# Function to update node
update_ritual() {
    echo -e "\n${BOLD}${BLUE}📈 Updating node...${NC}\n"

    json_1=~/infernet-container-starter/deploy/config.json
    json_2=~/infernet-container-starter/projects/hello-world/container/config.json
    temp_file=$(mktemp)

    echo -e "${WHITE}[${CYAN}1/2${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Updating configuration...${NC}"
    jq '.chain.snapshot_sync.sleep = 3 |
        .chain.snapshot_sync.batch_size = 9500 |
        .chain.snapshot_sync.starting_sub_id = 200000 |
        .chain.snapshot_sync.sync_period = 30' "$json_1" > "$temp_file"
    mv "$temp_file" "$json_1"

    jq '.chain.snapshot_sync.sleep = 3 |
        .chain.snapshot_sync.batch_size = 9500 |
        .chain.snapshot_sync.starting_sub_id = 200000 |
        .chain.snapshot_sync.sync_period = 30' "$json_2" > "$temp_file"
    mv "$temp_file" "$json_2"

    echo -e "${WHITE}[${CYAN}2/2${WHITE}] ${GREEN}➜ ${WHITE}🔄 Restarting services...${NC}"
    cd ~/infernet-container-starter/deploy && docker compose down

    echo -e "\n${GREEN}✅ Update completed!${NC}"
    echo -e "${YELLOW}Execute the command:${NC}"
    echo -e "${CYAN}cd ~/infernet-container-starter/deploy && docker compose up${NC}"
    echo -e "${CYAN}Visit https://x.com/Evenorchik for updates and support${NC}"
}

# Function to uninstall node
uninstall_ritual() {
    echo -e "\n${BOLD}${RED}⚠️ Uninstalling node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}⏹️ Stopping containers...${NC}"
    docker stop infernet-anvil infernet-node hello-world infernet-redis infernet-fluentbit
    docker rm -f infernet-anvil infernet-node hello-world infernet-redis infernet-fluentbit
    cd ~/infernet-container-starter/deploy && docker compose down

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}❌ Removing images...${NC}"
    docker image ls -a | grep "infernet" | awk '{print $3}' | xargs docker rmi -f
    docker image ls -a | grep "fluent-bit" | awk '{print $3}' | xargs docker rmi -f
    docker image ls -a | grep "redis" | awk '{print $3}' | xargs docker rmi -f

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🧹 Cleaning files...${NC}"
    rm -rf ~/foundry
    sed -i '/\/root\/.foundry\/bin/d' ~/.bashrc
    rm -rf ~/infernet-container-starter/projects/hello-world/contracts/lib
    cd $HOME
    rm -rf infernet-container-starter

    echo -e "\n${GREEN}✅ Node successfully uninstalled!${NC}"
    echo -e "${CYAN}Visit https://x.com/Evenorchik for updates and support${NC}"
}

# Function to check node status
check_node_status() {
    echo -e "\n${BOLD}${BLUE}📊 Checking node status...${NC}\n"
    
    # Check endpoint availability
    if curl -s localhost:4000/health > /dev/null; then
        response=$(curl -s localhost:4000/health)
        echo -e "${GREEN}✅ Node is working normally${NC}"
        echo -e "${CYAN}Response from node:${NC}"
        echo $response | jq '.'
    else
        echo -e "${RED}❌ Node is unavailable${NC}"
        echo -e "${YELLOW}Check that:${NC}"
        echo -e "  ${WHITE}1. Node is running${NC}"
        echo -e "  ${WHITE}2. Port 4000 is accessible${NC}"
        echo -e "  ${WHITE}3. All services are working correctly${NC}"
    fi
    echo -e "${CYAN}Visit https://x.com/Evenorchik for updates and support${NC}"
}

# Main menu
while true; do
    clear
    # Display logo
    curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/refs/heads/main/evenorlogo.sh | bash
    
    print_menu
    echo -e "${BOLD}${BLUE}📝 Enter action number [1-10]:${NC} "
    read -p "➜ " choice

    case $choice in
        1)
            install_ritual
            ;;
        2)
            install_ritual_2
            ;;
        3)
            install_ritual_3
            ;;
        4)
            restart_ritual
            ;;
        5)
            change_Wallet_Address
            ;;
        6)
            change_RPC_Address
            ;;
        7)
            update_ritual
            ;;
        8)
            uninstall_ritual
            ;;
        9)
            check_node_status
            ;;
        10)
            echo -e "\n${GREEN}👋 Goodbye!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${BOLD}${RED}❌ Error: Invalid choice! Please enter a number between 1 and 10.${NC}\n"
            ;;
    esac

    echo -e "\nPress Enter to return to menu..."
    read
done
