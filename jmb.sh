#!/bin/bash

# Definisi warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Fungsi untuk menampilkan pesan dengan warna
function print_message() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Fungsi untuk menampilkan halaman selamat datang
function welcome() {
    clear
    print_message "$YELLOW" "=================================="
    print_message "$GREEN" "      🌟 SELAMAT DATANG DI SCRIPT 🌟"
    print_message "$YELLOW" "=================================="
    echo "Sebelum melanjutkan, token Anda akan diverifikasi."
    print_message "$YELLOW" "=================================="
}

# Fungsi untuk meminta input token dari user
function input_token() {
    print_message "$GREEN" "Masukkan token Anda: "
    read -r TOKEN
}

# Fungsi untuk memverifikasi token
function verify_token() {
    print_message "$YELLOW" "Memverifikasi token..."
    echo -n "Memverifikasi token"
    for i in {1..3}; do
        echo -n "."
        sleep 1
    done
    echo ""

    # URL API
    API_URL="http://143.198.193.90:2101/verify-token/$TOKEN"
    
    # Memeriksa token menggunakan curl
    RESPONSE=$(curl -s "$API_URL")
    
    # Memeriksa apakah token valid
    if [[ $(echo "$RESPONSE" | jq -r '.valid') == "true" ]]; then
        EXPIRES_IN=$(echo "$RESPONSE" | jq -r '.expiresIn')
        CREATED_AT=$(echo "$RESPONSE" | jq -r '.createdAt')
        EXPIRES_AT=$(echo "$RESPONSE" | jq -r '.expiresAt')
        
        print_message "$GREEN" "AKSES BERHASIL."
        print_message "$YELLOW" "Token dibuat pada: $CREATED_AT"
        print_message "$YELLOW" "Token berlaku hingga: $EXPIRES_AT"
        print_message "$GREEN" "Sisa waktu berlaku: $EXPIRES_IN."
    else
        MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
        print_message "$RED" "AKSES GAGAL. $MESSAGE."
        exit 1
    fi
}

# Fungsi untuk menampilkan menu utama
function show_menu() {
    clear
    print_message "$YELLOW" "============================="
    print_message "$GREEN" "          MENU UTAMA         "
    print_message "$YELLOW" "============================="
    echo "1. Install Nebula"
    echo "2. Install Stellar"
    echo "3. Install Enigma"
    echo "4. Install Billing"
    echo "5. Keluar"
    print_message "$YELLOW" "============================="
    echo -n "Pilih opsi [1-5]: "
}

# Fungsi untuk menginstal NVM dan Node.js terbaru
function install_nvm_and_node() {
    print_message "$YELLOW" "Menginstal NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    print_message "$YELLOW" "Menginstal Node.js versi terbaru..."
    nvm install node
    nvm use node
    
    print_message "$GREEN" "Node.js versi terbaru berhasil diinstal."
}

# Fungsi untuk menginstal BlueprintFramework
function install_blueprint() {
    install_nvm_and_node
    
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

    sudo apt-get update
    sudo apt-get install -y nodejs
    npm install -g yarn
    cd /var/www/pterodactyl
    yarn install
    yarn add cross-env
    cd

    sudo apt install -y zip unzip git curl wget

    print_message "$YELLOW" "Mengunduh dan menginstal BlueprintFramework..."
    wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
    sudo mv release.zip /var/www/pterodactyl/release.zip
    cd /var/www/pterodactyl || exit
    sudo unzip release.zip

    sudo sed -i -E -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"www-data\" #;|g" \
    -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"/bin/bash\" #;|g" \
    -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"www-data:www-data\" #;|g" \
    /var/www/pterodactyl/blueprint.sh

    sudo chmod +x /var/www/pterodactyl/blueprint.sh

    print_message "$YELLOW" "Menjalankan BlueprintFramework..."
    sudo bash /var/www/pterodactyl/blueprint.sh <<< "A"

    print_message "$GREEN" "BlueprintFramework berhasil diinstal."

    print_message "$YELLOW" "Mengunduh nebula.blueprint..."
    wget https://github.com/DITZZ112/memew/blob/main/nebula.blueprint -O /var/www/pterodactyl/nebula.blueprint

    print_message "$YELLOW" "Menginstal Nebula Blueprint..."
    cd /var/www/pterodactyl
    blueprint -install nebula <<< ""

    print_message "$GREEN" "Nebula Blueprint berhasil diinstal."
    sleep 3
    rm -rf /var/www/pterodactyl/nebula.blueprint /var/www/pterodactyl/release.zip
    exit
}

# Fungsi untuk menginstal tema Stellar
function install_stellar() {
    if [ -e /root/pterodactyl ]; then
        print_message "$BLUE" "Menghapus direktori yang ada..."
        sudo rm -rf /root/pterodactyl || { print_message "$RED" "Gagal menghapus direktori /root/pterodactyl."; exit 1; }
    fi  

    print_message "$BLUE" "Mengunduh tema Stellar..."
    curl -L -o /root/stellar.zip https://github.com/DITZZ112/fox/raw/main/stellar.zip || { print_message "$RED" "Gagal mengunduh tema Stellar."; exit 1; }

    print_message "$BLUE" "Mengekstrak tema Stellar..."
    sudo unzip -o /root/stellar.zip -d /root/pterodactyl || { print_message "$RED" "Gagal mengekstrak tema Stellar."; exit 1; }
    sudo rm -rf /root/stellar.zip

    print_message "$BLUE" "Memulai instalasi tema Stellar..."
    sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    npm install -g yarn
    cd /var/www/pterodactyl
    yarn add react-feather
    php artisan migrate
    yarn build:production
    php artisan view:clear
    sudo rm -rf /root/pterodactyl

    print_message "$GREEN" "Instalasi Berhasil"
    sleep 2
    exit
}

# Fungsi untuk menginstal tema Enigma
function install_enigma() {
    if [ -e /root/pterodactyl ]; then
        print_message "$BLUE" "Menghapus direktori yang ada..."
        sudo rm -rf /root/pterodactyl || { print_message "$RED" "Gagal menghapus direktori /root/pterodactyl."; exit 1; }
    fi  

    print_message "$BLUE" "Mengunduh tema Enigma..."
    curl -L -o /root/enigma.zip https://github.com/DITZZ112/fox/raw/main/enigma.zip || { print_message "$RED" "Gagal mengunduh tema Enigma."; exit 1; }

    print_message "$BLUE" "Mengekstrak tema Enigma..."
    sudo unzip -o /root/enigma.zip -d /root/pterodactyl || { print_message "$RED" "Gagal mengekstrak tema Enigma."; exit 1; }
    sudo rm -rf /root/enigma.zip

    print_message "$BLUE" "Memulai instalasi tema Enigma..."
    echo -e "${YELLOW}Masukkan link WhatsApp (https://wa.me...) : ${NC}"
    read LINK_WA
    echo -e "${YELLOW}Masukkan link TikTok (https://tiktok.com...) : ${NC}"
    read LINK_TIKTOK
    echo -e "${YELLOW}Masukkan link Instagram (https://instagram.com...) : ${NC}"
    read LINK_INSTA

    sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
    cd /var/www/pterodactyl
    npm install --save linkifyjs
    npm install --save react-icons
    npm install --save @emotion/react @emotion/styled
    php artisan migrate
    yarn build:production
    php artisan view:clear
    sudo rm -rf /root/pterodactyl

    print_message "$GREEN" "Instalasi Berhasil"
    sleep 2
    exit
}

# Fungsi utama
function main() {
    welcome
    input_token
    verify_token
    
    while true; do
        show_menu
        read -r CHOICE
        
        case $CHOICE in
            1)
                install_blueprint
                ;;
            2)
                install_stellar
                ;;
            3)
                install_enigma
                ;;
            4)
                # install_billing
                print_message "$YELLOW" "Fungsi install_billing belum diimplementasikan."
                ;;
            5)
                print_message "$GREEN" "Keluar dari skrip..."
                exit 0
                ;;
            *)
                print_message "$RED" "Pilihan tidak valid, silakan coba lagi."
                ;;
        esac
    done
}

main
