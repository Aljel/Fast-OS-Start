#!/bin/bash

# Обновить систему
sudo apt update && sudo apt upgrade -y

# Установить C++ (gcc/g++ и все нужное)
sudo apt install -y build-essential

# Установить Go (golang-go)
sudo apt install -y golang-go

# Установить Telegram
sudo apt install -y telegram-desktop

# Установить wget и gdebi (потребуются далее)
sudo apt install -y wget gdebi-core

# Установить VS Code
wget -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo gdebi -n /tmp/vscode.deb

# Установить Anytype (скачать deb, установить)
wget -O /tmp/anytype.deb "https://anytype.io/downloads/anytype_amd64.deb"
sudo gdebi -n /tmp/anytype.deb

# Установить Element
wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list
sudo apt update
sudo apt install -y element-desktop

# Установить Google Chrome
wget -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
sudo gdebi -n /tmp/chrome.deb

echo "Установка завершена!"
