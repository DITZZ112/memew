#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fungsi untuk menampilkan halaman selamat datang
function welcome() {
    clear
    echo -e "${YELLOW}==================================${NC}"
    echo -e "      ${GREEN}🌟 SELAMAT DATANG DI SCRIPT 🌟${NC}"
    echo -e "${YELLOW}==================================${NC}"
    echo "Sebelum melanjutkan, token Anda akan diverifikasi."
    echo -e "${YELLOW}==================================${NC}"
}

# Fungsi untuk meminta input token dari user
function input_token() {
    echo -e "${GREEN}Masukkan token Anda: ${NC}"
    read -r TOKEN
}

# Fungsi untuk memverifikasi token
function verify_token() {
    # Pengaturan warna
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # Tanpa warna

    echo "Memverifikasi token..."
    echo -n "Memverifikasi token"
    for i in {1..3}; do
        echo -n "."
        sleep 1
    done
    echo ""

    # URL API
    API_URL="http://143.198.193.90:2101/verify-token/$USER_TOKEN"
    
    # Memeriksa token menggunakan curl
    RESPONSE=$(curl -s "$API_URL")
    
    # Memeriksa apakah token valid
    VALID=$(echo "$RESPONSE" | grep -o '"valid":true')

    if [ "$VALID" = '"valid":true' ]; then
        EXPIRES_IN=$(echo "$RESPONSE" | grep -oP '"expiresIn":"\K[^"]+')
        CREATED_AT=$(echo "$RESPONSE" | grep -oP '"createdAt":"\K[^"]+')
        EXPIRES_AT=$(echo "$RESPONSE" | grep -oP '"expiresAt":"\K[^"]+')
        
        echo -e "${GREEN}AKSES BERHASIL.${NC}"
        echo -e "${YELLOW}Token dibuat pada: $CREATED_AT${NC}"
        echo -e "${YELLOW}Token berlaku hingga: $EXPIRES_AT${NC}"
        echo -e "${GREEN}Sisa waktu berlaku: $EXPIRES_IN.${NC}"
       
        display_menu
    else
        MESSAGE=$(echo "$RESPONSE" | grep -oP '"message":"\K[^"]+')
        echo -e "${RED}AKSES GAGAL. $MESSAGE.${NC}"
        exit 1
    fi
}



# Fungsi untuk menampilkan menu utama
function show_menu() {
    clear
    echo "============================="
    echo "          MENU UTAMA         "
    echo "============================="
    echo "1. Install Nebula"
    echo "2. Install Stellar"
    echo "3. Install Enigma"
    echo "4. Install Billing"
    echo "5. Keluar"
    echo "============================="
    echo -n "Pilih opsi [1-5]: "
}

# Fungsi untuk menginstal NVM dan Node.js terbaru
function install_nvm_and_node() {
    echo -e "${YELLOW}Menginstal NVM (Node Version Manager)...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    
    # Memuat NVM ke sesi saat ini
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    echo -e "${YELLOW}Menginstal Node.js versi terbaru...${NC}"
    nvm install node
    
    # Menggunakan versi terbaru dari Node.js
    nvm use node
    
    echo -e "${GREEN}Node.js versi terbaru berhasil diinstal.${NC}"
}
# Fungsi untuk mengunduh dan menginstal BlueprintFramework
function install_blueprint() {
    install_nvm_and_node
    
    echo "Menginstal paket yang diperlukan..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

    sudo apt-get update
    sudo apt-get install -y nodejs
    npm i -g yarn
    cd /var/www/pterodactyl
    yarn
    yarn add cross-env
    cd

    sudo apt install -y zip unzip git curl wget

    echo "Mengunduh dan menginstal BlueprintFramework..."
    wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
    sudo mv release.zip /var/www/pterodactyl/release.zip
    cd /var/www/pterodactyl || exit
    sudo unzip release.zip

    FOLDER="/var/www/pterodactyl"
    WEBUSER="www-data"
    USERSHELL="/bin/bash"
    PERMISSIONS="www-data:www-data"

    sudo sed -i -E -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" \
    -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" \
    -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$PERMISSIONS\" #;|g" \
    $FOLDER/blueprint.sh

    sudo chmod +x $FOLDER/blueprint.sh

    echo "Menjalankan BlueprintFramework..."
    sudo bash $FOLDER/blueprint.sh <<EOF
A
EOF

    echo "BlueprintFramework berhasil diinstal."

    echo "Mengunduh nebula.blueprint..."
    wget https://github.com/DITZZ112/memew/blob/main/nebula.blueprint -O /var/www/pterodactyl/nebula.blueprint

    echo "Menginstal Nebula Blueprint..."
    cd /var/www/pterodactyl
    blueprint -install nebula  <<EOF


EOF

    echo "Nebula Blueprint berhasil diinstal."
    sleep 3
    rm -rf nebula.blueprint release.zip
    exit
}

# Fungsi umum untuk mengunduh dan menginstal tema
function install_stellar() {
# Memastikan direktori /root/pterodactyl tidak ada
    if [ -e /root/pterodactyl ]; then
        echo -e "${BLUE}Menghapus direktori yang ada...${NC}"
        sudo rm -rf /root/pterodactyl
        if [ $? -ne 0 ]; then
            echo -e "${RED}Gagal menghapus direktori /root/pterodactyl.${NC}"
            exit 1
        fi
    fi  

    # Mengunduh file zip tema Stellar
    echo -e "${BLUE}Mengunduh tema Stellar...${NC}"
    curl -L -o /root/stellar.zip https://github.com/DITZZ112/fox/raw/main/stellar.zip
    if [ $? -ne 0 ]; then
        echo -e "${RED}Gagal mengunduh tema Stellar.${NC}"
        exit 1
    fi

    # Mengekstrak file tema
    echo -e "${BLUE}Mengekstrak tema Stellar...${NC}"
    sudo unzip -o /root/stellar.zip -d /root/pterodactyl
    if [ $? -ne 0 ]; then
        echo -e "${RED}Gagal mengekstrak tema Stellar.${NC}"
        exit 1
    fi
  sudo rm -rf /root/stellar.zip
  # Instalation process
  echo -e "${BLUE}Memulai instalasi tema Stellar...${NC}"
  sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
  curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
  sudo npm i -g yarn
  cd /var/www/pterodactyl
  yarn add react-feather
  php artisan migrate
  yarn build:production
  php artisan view:clear
  sudo rm -rf /root/stellar.zip
  sudo rm -rf /root/pterodactyl
  echo -e "${GREEN}Instalasi Berhasil${NC}"
  sleep 2
  exit
}

function install_enigma() {
# Memastikan direktori /root/pterodactyl tidak ada
    if [ -e /root/pterodactyl ]; then
        echo -e "${BLUE}Menghapus direktori yang ada...${NC}"
        sudo rm -rf /root/pterodactyl
        if [ $? -ne 0 ]; then
            echo -e "${RED}Gagal menghapus direktori /root/pterodactyl.${NC}"
            exit 1
        fi
    fi  

    # Mengunduh file zip tema Stellar
    echo -e "${BLUE}Mengunduh tema Enigma...${NC}"
    curl -L -o /root/enigma.zip https://github.com/DITZZ112/fox/raw/main/enigma.zip
    if [ $? -ne 0 ]; then
        echo -e "${RED}Gagal mengunduh tema Enigma.${NC}"
        exit 1
    fi

    # Mengekstrak file tema
    echo -e "${BLUE}Mengekstrak tema Enigma...${NC}"
    sudo unzip -o /root/Enigma.zip -d /root/pterodactyl
    if [ $? -ne 0 ]; then
        echo -e "${RED}Gagal mengekstrak tema Enigma.${NC}"
        exit 1
    fi
   sudo rm -rf /root/Enigma.zip
  # Instalation process
  echo -e "${BLUE}Memulai instalasi tema Enigma...${NC}"
# Menanyakan informasi kepada pengguna untuk tema Enigma
      echo -e "${YELLOW}Masukkan link WhatsApp (https://wa.me...) : ${NC}"
      read LINK_WA
      echo -e "${YELLOW}Masukkan link group (https://.....) : ${NC}"
      read LINK_GROUP
      echo -e "${YELLOW}Masukkan link channel (https://...) : ${NC}"
      read LINK_CHNL

      # Mengganti placeholder dengan nilai dari pengguna
      sudo sed -i "s|LINK_WA|$LINK_WA|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
      sudo sed -i "s|LINK_GROUP|$LINK_GROUP|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
      sudo sed -i "s|LINK_CHNL|$LINK_CHNL|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
  
  #instalasi thema
  sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
  curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
  sudo npm i -g yarn
  cd /var/www/pterodactyl
  yarn add react-feather
  php artisan migrate
  yarn build:production
  php artisan view:clear
  sudo rm -rf /root/pterodactyl

  echo -e "${GREEN}Instalasi Berhasil${NC}"
  sleep 2
  clear
  exit  
  
}

# Loop utama untuk menampilkan menu sampai pengguna memilih untuk keluar
function main_menu() {
    while true; do
        show_menu
        read -r choice
        case $choice in
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
                install_billing
                ;;
            5)
                echo "Keluar dari menu. Sampai jumpa!"
                exit 0
                ;;
            *)
                echo "Opsi tidak valid. Silakan coba lagi."
                ;;
        esac
    done
}

# Jalankan script dari halaman selamat datang
welcome
input_token
verify_token
main_menu
