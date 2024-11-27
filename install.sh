#!/bin/bash

# Definisi warna untuk mempermudah pembacaan teks
HIJAU='\033[0;32m'
MERAH='\033[0;31m'
KUNING='\033[1;33m'
RESET='\033[0m' # Reset warna ke default

# Direktori kerja tempat skrip akan dijalankan
WORK_DIR="/root/soniclabsbot"

# Informasi awal saat menjalankan skrip
echo -e "${HIJAU}Memulai instalasi bot Soniclabs.${RESET}"
echo -e "${HIJAU}Skrip ini dibuat oleh: https://t.me/kjkresearch${RESET}"
echo -e "${HIJAU}Sumber: https://github.com/airdropinsiders/soniclabsbot${RESET}"

# Menampilkan pilihan kepada pengguna
echo -e "${HIJAU}Silakan pilih opsi berikut:${RESET}"
echo -e "${KUNING}1. Instal baru bot Soniclabs${RESET}"
echo -e "${KUNING}2. Gunakan data yang sudah ada (jalankan ulang bot)${RESET}"
echo -e "${KUNING}3. Perbarui bot Soniclabs${RESET}"
read -p "Pilihan Anda: " pilihan

# Proses berdasarkan pilihan pengguna
case $pilihan in
  1)
    echo -e "${HIJAU}Menginstal ulang Soniclabs.${RESET}"
    
    # Menginstal Python dan paket-paket yang diperlukan
    echo -e "${KUNING}Memperbarui sistem dan memasang paket yang diperlukan...${RESET}"
    rm -rf $WORK_DIR
    sudo apt update
    sudo apt install -y git

    # Mengambil kode dari GitHub
    [ -d "$WORK_DIR" ] && rm -rf $WORK_DIR
    echo -e "${KUNING}Mengunduh kode dari GitHub...${RESET}"
    git clone https://github.com/airdropinsiders/soniclabsbot.git $WORK_DIR

    # Membuat dan berpindah ke direktori kerja
    echo -e "${KUNING}Berpindah ke direktori kerja...${RESET}"
    cd $WORK_DIR

    # Menginstal Node.js versi LTS (Long Term Support)
    echo -e "${KUNING}Menginstal dan mengatur Node.js versi LTS...${RESET}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Memuat NVM
    nvm install --lts
    nvm use --lts
    npm install
    cp -r accounts/accounts_tmp.js accounts/accounts.js && cp -r config/proxy_list_tmp.js config/proxy_list.js

    # Langkah yang harus dilakukan pengguna
    echo -e "${HIJAU}Sebelum menjalankan bot, selesaikan langkah-langkah berikut. Tekan Enter setelah selesai.${RESET}"
    read -p "1. Kunjungi: https://testnet.soniclabs.com/account dan klaim Faucet."
    read -p "2. Daftar di platform ini: https://airdrop.soniclabs.com/?ref=0pyxta."
    read -p "3. Pergi ke: https://arcade.soniclabs.com/ dan klaim Faucet lagi di langkah kedua (gunakan akun Twitter)."
    read -p "4. Pastikan alamat dompet di kanan atas adalah Smart Wallet Anda."
    read -p "5. Mainkan game seperti Plinko, Mine, dan Wheel masing-masing satu kali."

    # Meminta pengguna untuk memasukkan informasi akun
    echo -e "${HIJAU}Masukkan informasi akun Anda.${RESET}"
    read -p "Masukkan private key (pisahkan dengan koma): " account
    read -p "Masukkan alamat Smart Wallet (pisahkan dengan koma): " wallet_addresses

    # Memasukkan informasi proxy
    echo -e "${KUNING}Masukkan informasi proxy dalam format: http://proxyUser:proxyPass@IP:Port${RESET}"
    echo -e "${KUNING}Gunakan baris baru untuk memisahkan beberapa proxy.${RESET}"
    echo -e "${KUNING}Tekan Enter dua kali untuk menyelesaikan.${RESET}"

    proxy_array=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        proxy_array+=("$line")
    done

    # Menyimpan proxy ke file
    {
        echo "export const proxyList = ["
        for proxy in "${proxy_array[@]}"; do
            echo "    \"$proxy\","
        done
        echo "];"
    } > $WORK_DIR/config/proxy_list.js 

    # Memisahkan dan menyimpan private key serta Smart Wallet Address
    IFS=',' read -r -a private_keys <<< "$account"
    IFS=',' read -r -a smart_wallet_addresses <<< "$wallet_addresses"

    # Menyimpan informasi wallet ke file
    {
        echo "export const privateKey = ["
        for i in "${!private_keys[@]}"; do
            echo "  {"
            echo "    pk: \"${private_keys[i]}\","
            echo "    smartWalletAddress: \"${smart_wallet_addresses[i]}\","
            echo "  },"
        done
        echo "];"
    } > $WORK_DIR/accounts/accounts.js

    # Mengaktifkan fitur tampilan poin
    sed -i 's/static DISPLAYPOINT = false;/static DISPLAYPOINT = true;/' $WORK_DIR/config/config.js

    # Menjalankan bot
    npm install sqlite3
    npm install sqlite 
    npm run start
    ;;

  2)
    echo -e "${HIJAU}Menjalankan ulang Soniclabs.${RESET}"
    cd $WORK_DIR
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm run start
    ;;

  3)
    echo -e "${HIJAU}Memperbarui Soniclabs.${RESET}"
    cd $WORK_DIR
    git pull
    git pull --rebase
    git stash && git pull
    npm update
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm run start
    ;;

  *)
    echo -e "${MERAH}Pilihan tidak valid. Silakan coba lagi.${RESET}"
    ;;
esac
