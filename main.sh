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

set -e

# Установка базовых утилит
sudo apt install -y ca-certificates curl gnupg lsb-release

# Подготовка директории для ключей
sudo install -m 0755 -d /etc/apt/keyrings

# Получение GPG-ключа Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.asc

# Добавление официального Docker-репозитория
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновление кэша apt и установка Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Включение и запуск демона Docker
sudo systemctl enable --now docker

# (Опционально) Добавление текущего пользователя в группу docker
sudo usermod -aG docker $USER


# Установка curl, если он еще не установлен
sudo apt update
sudo apt install -y curl

# Установка rustup и Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Экспорт переменных окружения (сделать rustc/cargo доступными сразу)
export PATH="$HOME/.cargo/bin:$PATH"

rustc -V
cargo -V

echo "Rust успешно установлен. Для доступа к командам перезапустите терминал или выполните:"
echo 'source $HOME/.cargo/env'
echo "Docker успешно установлен. Выйдите из системы и войдите снова, чтобы применять группу docker."
docker --version
docker compose version
echo "Установка завершена!"
