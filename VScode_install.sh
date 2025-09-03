#!/bin/bash

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Сброс цвета

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Установка Visual Studio Code       ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
   echo -e "${YELLOW}Используйте: bash install_vscode.sh${NC}"
   exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

# Проверка существующей установки
if command -v code &> /dev/null; then
    echo -e "${YELLOW}VS Code уже установлен:${NC}"
    code --version | head -1
    echo -e "${CYAN}Хотите переустановить VS Code? (y/n):${NC}"
    read -r reinstall
    if [[ $reinstall != "y" && $reinstall != "Y" ]]; then
        echo -e "${GREEN}Установка отменена${NC}"
        exit 0
    fi
fi

echo -e "${CYAN}Выберите метод установки:${NC}"
echo -e "${PURPLE}1)${NC} Официальный репозиторий Microsoft (рекомендуется)"
echo -e "${PURPLE}2)${NC} Snap пакет"
echo -e "${PURPLE}3)${NC} .deb пакет (прямая загрузка)"
echo -e "${PURPLE}4)${NC} Flatpak"
echo -e "${CYAN}Ваш выбор (1-4):${NC}"
read -r choice

case $choice in
    1)
        echo -e "${YELLOW}Установка через официальный репозиторий Microsoft...${NC}"
        
        echo -e "${YELLOW}Шаг 1: Установка зависимостей...${NC}"
        sudo apt update
        sudo apt install -y \
            wget \
            gpg \
            apt-transport-https \
            software-properties-common
        
        echo -e "${YELLOW}Шаг 2: Импорт GPG ключа Microsoft...${NC}"
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        
        echo -e "${YELLOW}Шаг 3: Установка VS Code...${NC}"
        sudo apt update
        sudo apt install -y code
        
        echo -e "${GREEN}✓ VS Code установлен через официальный репозиторий${NC}"
        ;;
        
    2)
        echo -e "${YELLOW}Установка через Snap...${NC}"
        
        # Проверяем, установлен ли snapd
        if ! command -v snap &> /dev/null; then
            echo -e "${YELLOW}Устанавливаем snapd...${NC}"
            sudo apt update
            sudo apt install -y snapd
        fi
        
        # Устанавливаем VS Code через snap
        sudo snap install --classic code
        
        echo -e "${GREEN}✓ VS Code установлен через Snap${NC}"
        ;;
        
    3)
        echo -e "${YELLOW}Установка .deb пакета...${NC}"
        
        echo -e "${YELLOW}Загружаем .deb пакет...${NC}"
        cd /tmp
        wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
        
        echo -e "${YELLOW}Устанавливаем пакет...${NC}"
        sudo apt update
        sudo apt install -y ./vscode.deb
        
        echo -e "${GREEN}✓ VS Code установлен из .deb пакета${NC}"
        ;;
        
    4)
        echo -e "${YELLOW}Установка через Flatpak...${NC}"
        
        # Проверяем, установлен ли Flatpak
        if ! command -v flatpak &> /dev/null; then
            echo -e "${YELLOW}Устанавливаем Flatpak...${NC}"
            sudo apt update
            sudo apt install -y flatpak
            sudo apt install -y gnome-software-plugin-flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
        
        # Устанавливаем VS Code через Flatpak
        flatpak install flathub com.visualstudio.code -y
        
        echo -e "${GREEN}✓ VS Code установлен через Flatpak${NC}"
        ;;
        
    *)
        echo -e "${RED}Неверный выбор. Используем официальный репозиторий...${NC}"
        choice=1
        # Повторяем установку метода 1
        sudo apt update
        sudo apt install -y wget gpg apt-transport-https software-properties-common
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt update
        sudo apt install -y code
        echo -e "${GREEN}✓ VS Code установлен через официальный репозиторий${NC}"
        ;;
esac

echo -e "${YELLOW}Установка полезных расширений...${NC}"

# Функция для установки расширений
install_extension() {
    local ext_id=$1
    local ext_name=$2
    echo -e "${CYAN}Устанавливаем ${ext_name}...${NC}"
    
    case $choice in
        2)
            snap run code --install-extension "$ext_id" 2>/dev/null || echo -e "${YELLOW}⚠️ Не удалось установить ${ext_name}${NC}"
            ;;
        4)
            flatpak run com.visualstudio.code --install-extension "$ext_id" 2>/dev/null || echo -e "${YELLOW}⚠️ Не удалось установить ${ext_name}${NC}"
            ;;
        *)
            code --install-extension "$ext_id" 2>/dev/null || echo -e "${YELLOW}⚠️ Не удалось установить ${ext_name}${NC}"
            ;;
    esac
}

# Список популярных расширений
echo -e "${CYAN}Устанавливаем популярные расширения:${NC}"

install_extension "ms-python.python" "Python"
install_extension "ms-vscode.cpptools" "C/C++"
install_extension "golang.go" "Go"
install_extension "rust-lang.rust-analyzer" "Rust Analyzer"
install_extension "bradlc.vscode-tailwindcss" "Tailwind CSS"
install_extension "esbenp.prettier-vscode" "Prettier"
install_extension "ms-vscode.vscode-json" "JSON"
install_extension "ms-vscode.vscode-typescript-next" "TypeScript"
install_extension "formulahendry.auto-rename-tag" "Auto Rename Tag"
install_extension "PKief.material-icon-theme" "Material Icon Theme"
install_extension "Equinusocio.vsc-material-theme" "Material Theme"
install_extension "ms-vsliveshare.vsliveshare" "Live Share"
install_extension "GitHub.copilot" "GitHub Copilot"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка завершена!          ${NC}"
echo -e "${GREEN}======================================${NC}"
