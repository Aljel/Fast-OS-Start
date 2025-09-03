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
echo -e "${BLUE}      Установка Telegram Desktop      ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
   echo -e "${YELLOW}Используйте: bash install_telegram.sh${NC}"
   exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

# Проверка существующей установки
if command -v telegram-desktop &> /dev/null; then
    echo -e "${YELLOW}Telegram уже установлен${NC}"
    echo -e "${CYAN}Хотите переустановить Telegram? (y/n):${NC}"
    read -r reinstall
    if [[ $reinstall != "y" && $reinstall != "Y" ]]; then
        echo -e "${GREEN}Установка отменена${NC}"
        exit 0
    fi
fi

echo -e "${CYAN}Выберите метод установки:${NC}"
echo -e "${PURPLE}1)${NC} Snap (рекомендуется) - автоматические обновления"
echo -e "${PURPLE}2)${NC} APT - из официальных репозиториев"
echo -e "${PURPLE}3)${NC} Flatpak - универсальный пакет"
echo -e "${PURPLE}4)${NC} Официальный архив - прямая загрузка"
echo -e "${CYAN}Ваш выбор (1-4):${NC}"
read -r choice

case $choice in
    1)
        echo -e "${YELLOW}Установка через Snap...${NC}"
        
        # Проверяем, установлен ли snapd
        if ! command -v snap &> /dev/null; then
            echo -e "${YELLOW}Устанавливаем snapd...${NC}"
            sudo apt update
            sudo apt install -y snapd
        fi
        
        # Устанавливаем Telegram через snap
        sudo snap install telegram-desktop
        
        echo -e "${GREEN}✓ Telegram установлен через Snap${NC}"
        ;;
        
    2)
        echo -e "${YELLOW}Установка через APT...${NC}"
        
        sudo apt update
        
        # Проверяем доступность в репозитории
        if apt-cache search telegram-desktop | grep -q telegram-desktop; then
            sudo apt install -y telegram-desktop
            echo -e "${GREEN}✓ Telegram установлен через APT${NC}"
        else
            echo -e "${YELLOW}Telegram не найден в стандартных репозиториях${NC}"
            echo -e "${YELLOW}Добавляем PPA репозиторий...${NC}"
            
            # Устанавливаем зависимости
            sudo apt install -y software-properties-common
            
            # Добавляем PPA
            sudo add-apt-repository ppa:atareao/telegram -y
            sudo apt update
            sudo apt install -y telegram
            
            echo -e "${GREEN}✓ Telegram установлен через PPA${NC}"
        fi
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
        
        # Устанавливаем Telegram через Flatpak
        flatpak install flathub org.telegram.desktop -y
        
        echo -e "${GREEN}✓ Telegram установлен через Flatpak${NC}"
        ;;
        
    4)
        echo -e "${YELLOW}Установка официального архива...${NC}"
        
        # Создаем директорию для установки
        INSTALL_DIR="/opt/Telegram"
        sudo mkdir -p "$INSTALL_DIR"
        
        # Загружаем последнюю версию
        cd /tmp
        echo -e "${YELLOW}Загружаем последнюю версию Telegram...${NC}"
        wget -O telegram.tar.xz "https://telegram.org/dl/desktop/linux"
        
        # Извлекаем архив
        tar -xf telegram.tar.xz
        
        # Перемещаем в /opt
        sudo rm -rf "$INSTALL_DIR"
        sudo mv Telegram "$INSTALL_DIR"
        
        # Создаем символическую ссылку
        sudo ln -sf "$INSTALL_DIR/Telegram" /usr/local/bin/telegram-desktop
        
        # Создаем desktop файл
        cat > ~/.local/share/applications/telegram-desktop.desktop << EOF
[Desktop Entry]
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
Exec=/opt/Telegram/Telegram -- %u
Icon=/opt/Telegram/telegram.png
Terminal=false
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF
        
        # Делаем desktop файл исполняемым
        chmod +x ~/.local/share/applications/telegram-desktop.desktop
        
        # Обновляем базу данных приложений
        update-desktop-database ~/.local/share/applications/
        
        echo -e "${GREEN}✓ Telegram установлен из официального архива${NC}"
        ;;
        
    *)
        echo -e "${RED}Неверный выбор. Используем Snap по умолчанию...${NC}"
        
        if ! command -v snap &> /dev/null; then
            sudo apt update
            sudo apt install -y snapd
        fi
        
        sudo snap install telegram-desktop
        echo -e "${GREEN}✓ Telegram установлен через Snap${NC}"
        ;;
esac

echo -e "${YELLOW}Шаг 2: Установка дополнительных зависимостей...${NC}"
sudo apt update
sudo apt install -y \
    libnotify-bin \
    libappindicator3-1 \
    libxss1 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка завершена!          ${NC}"
echo -e "${GREEN}======================================${NC}"

# Проверка установки
echo -e "${BLUE}Проверка установки:${NC}"
if command -v telegram-desktop &> /dev/null; then
    echo -e "${GREEN}✓ Telegram Desktop найден в системе${NC}"
    
    # Пытаемся получить версию
    if telegram-desktop --version &> /dev/null; then
        echo -e "${GREEN}✓ Telegram готов к запуску${NC}"
    fi
elif snap list telegram-desktop &> /dev/null; then
    echo -e "${GREEN}✓ Telegram установлен через Snap${NC}"
elif flatpak list | grep -q telegram; then
    echo -e "${GREEN}✓ Telegram установлен через Flatpak${NC}"
else
    echo -e "${YELLOW}⚠️  Проверьте установку вручную${NC}"
fi
