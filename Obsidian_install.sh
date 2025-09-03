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
echo -e "${BLUE}        Установка Obsidian            ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
   echo -e "${YELLOW}Используйте: bash install_obsidian.sh${NC}"
   exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

# Проверка существующей установки
if command -v obsidian &> /dev/null; then
    echo -e "${YELLOW}Obsidian уже установлен${NC}"
    echo -e "${CYAN}Хотите переустановить Obsidian? (y/n):${NC}"
    read -r reinstall
    if [[ $reinstall != "y" && $reinstall != "Y" ]]; then
        echo -e "${GREEN}Установка отменена${NC}"
        exit 0
    fi
fi

echo -e "${CYAN}Выберите метод установки:${NC}"
echo -e "${PURPLE}1)${NC} Автоматическая установка AppImage (рекомендуется)"
echo -e "${PURPLE}2)${NC} Snap пакет"
echo -e "${PURPLE}3)${NC} Flatpak"
echo -e "${PURPLE}4)${NC} Ручная установка AppImage"
echo -e "${CYAN}Ваш выбор (1-4):${NC}"
read -r choice

case $choice in
    1)
        echo -e "${YELLOW}Автоматическая установка AppImage...${NC}"
        
        echo -e "${YELLOW}Шаг 1: Установка зависимостей...${NC}"
        sudo apt update
        sudo apt install -y \
            wget \
            curl \
            ca-certificates \
            libfuse2 \
            libnss3-dev \
            libatk1.0-0 \
            libdrm2 \
            libxkbcommon0 \
            libxcomposite1 \
            libxdamage1 \
            libxrandr2 \
            libgbm1 \
            libxss1 \
            libasound2
        
        echo -e "${YELLOW}Шаг 2: Загрузка и установка последней версии...${NC}"
        
        # Используем готовый установочный скрипт
        if curl -fsSL https://raw.githubusercontent.com/oviniciusfeitosa/obsidian-ubuntu-installer/main/install.sh | sh; then
            echo -e "${GREEN}✓ Obsidian установлен автоматически${NC}"
        else
            echo -e "${RED}Ошибка автоматической установки. Попробуем ручной метод...${NC}"
            choice=4
        fi
        ;;
        
    2)
        echo -e "${YELLOW}Установка через Snap...${NC}"
        
        # Проверяем, установлен ли snapd
        if ! command -v snap &> /dev/null; then
            echo -e "${YELLOW}Устанавливаем snapd...${NC}"
            sudo apt update
            sudo apt install -y snapd
        fi
        
        # Устанавливаем Obsidian через snap
        sudo snap install obsidian --classic
        
        echo -e "${GREEN}✓ Obsidian установлен через Snap${NC}"
        ;;
        
    3)
        echo -e "${YELLOW}Установка через Flatpak...${NC}"
        
        # Проверяем, установлен ли Flatpak
        if ! command -v flatpak &> /dev/null; then
            echo -e "${YELLOW}Устанавливаем Flatpak...${NC}"
            sudo apt update
            sudo apt install -y flatpak
            sudo apt install -y gnome-software-plugin-flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
        
        # Устанавливаем Obsidian через Flatpak
        flatpak install flathub md.obsidian.Obsidian -y
        
        echo -e "${GREEN}✓ Obsidian установлен через Flatpak${NC}"
        ;;
        
    4)
        echo -e "${YELLOW}Ручная установка AppImage...${NC}"
        ;;
        
    *)
        echo -e "${RED}Неверный выбор. Используем автоматическую установку...${NC}"
        choice=1
        ;;
esac

# Ручная установка AppImage (если выбран метод 4 или автоматическая не сработала)
if [ "$choice" = "4" ] || [ "$choice" = "1" ]; then
    echo -e "${YELLOW}Ручная установка AppImage...${NC}"
    
    echo -e "${YELLOW}Шаг 1: Установка зависимостей...${NC}"
    sudo apt update
    sudo apt install -y \
        wget \
        curl \
        ca-certificates \
        libfuse2 \
        libnss3-dev
    
    echo -e "${YELLOW}Шаг 2: Создание директории установки...${NC}"
    mkdir -p /tmp/obsidian-install
    cd /tmp/obsidian-install
    
    echo -e "${YELLOW}Шаг 3: Загрузка последней версии Obsidian...${NC}"
    # Получаем ссылку на последнюю версию AppImage
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep "browser_download_url.*AppImage" | grep -v "arm64" | cut -d : -f 2,3 | tr -d \")
    
    if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "${RED}Не удалось получить ссылку на загрузку${NC}"
        exit 1
    fi
    
    wget "$DOWNLOAD_URL"
    APPIMAGE_FILE=$(ls *.AppImage | head -1)
    
    echo -e "${YELLOW}Шаг 4: Извлечение AppImage...${NC}"
    chmod +x "$APPIMAGE_FILE"
    ./"$APPIMAGE_FILE" --appimage-extract
    
    echo -e "${YELLOW}Шаг 5: Установка в систему...${NC}"
    sudo rm -rf /opt/Obsidian
    sudo mv squashfs-root /opt/Obsidian
    
    echo -e "${YELLOW}Шаг 6: Настройка прав доступа...${NC}"
    sudo chown -R root: /opt/Obsidian
    sudo chmod 4755 /opt/Obsidian/chrome-sandbox
    sudo find /opt/Obsidian -type d -exec chmod 755 {} \;
    
    echo -e "${YELLOW}Шаг 7: Создание символической ссылки...${NC}"
    sudo ln -sf /opt/Obsidian/AppRun /usr/local/bin/obsidian
    
    echo -e "${YELLOW}Шаг 8: Создание desktop файла...${NC}"
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/obsidian.desktop << 'EOF'
[Desktop Entry]
Name=Obsidian
Comment=A powerful knowledge base that works on top of a local folder of plain text Markdown files
Exec=/usr/local/bin/obsidian
Icon=/opt/Obsidian/obsidian.png
Terminal=false
Type=Application
Categories=Office;Utility;
StartupWMClass=obsidian
MimeType=text/markdown;
EOF
    
    chmod +x ~/.local/share/applications/obsidian.desktop
    update-desktop-database ~/.local/share/applications/
    
    echo -e "${GREEN}✓ Obsidian установлен вручную${NC}"
fi

echo -e "${YELLOW}Установка дополнительных зависимостей...${NC}"
sudo apt install -y \
    fonts-noto \
    fonts-noto-color-emoji \
    fonts-liberation \
    ttf-mscorefonts-installer

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка завершена!          ${NC}"
echo -e "${GREEN}======================================${NC}"
