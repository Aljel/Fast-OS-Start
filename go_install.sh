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
echo -e "${BLUE}      Установка Go (Golang)          ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
   echo -e "${YELLOW}Используйте: bash install_golang.sh${NC}"
   exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

# Проверка существующей установки
if command -v go &> /dev/null; then
    echo -e "${YELLOW}Go уже установлен:${NC}"
    go version
    echo -e "${CYAN}Хотите переустановить Go? (y/n):${NC}"
    read -r reinstall
    if [[ $reinstall != "y" && $reinstall != "Y" ]]; then
        echo -e "${GREEN}Установка отменена${NC}"
        exit 0
    fi
    echo -e "${YELLOW}Удаляем существующую установку...${NC}"
    sudo rm -rf /usr/local/go
fi

echo -e "${YELLOW}Шаг 1: Обновление системы...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${YELLOW}Шаг 2: Установка зависимостей...${NC}"
sudo apt install -y \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates

echo -e "${YELLOW}Шаг 3: Определение последней версии Go...${NC}"
# Получаем последнюю версию Go
LATEST_VERSION=$(curl -s https://api.github.com/repos/golang/go/releases/latest | grep '"tag_name":' | sed -E 's/.*"go([^"]+)".*/\1/')
if [ -z "$LATEST_VERSION" ]; then
    LATEST_VERSION="1.22.6"  # Fallback версия
    echo -e "${YELLOW}Используем fallback версию: ${LATEST_VERSION}${NC}"
else
    echo -e "${GREEN}Найдена последняя версия: ${LATEST_VERSION}${NC}"
fi

echo -e "${YELLOW}Шаг 4: Загрузка Go ${LATEST_VERSION}...${NC}"
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    GO_ARCH="amd64"
elif [ "$ARCH" = "arm64" ]; then
    GO_ARCH="arm64"
elif [ "$ARCH" = "armhf" ]; then
    GO_ARCH="armv6l"
else
    GO_ARCH="amd64"  # По умолчанию
fi

GO_TAR="go${LATEST_VERSION}.linux-${GO_ARCH}.tar.gz"
cd /tmp
wget "https://golang.org/dl/${GO_TAR}"

echo -e "${YELLOW}Шаг 5: Установка Go...${NC}"
sudo tar -C /usr/local -xzf "${GO_TAR}"

echo -e "${YELLOW}Шаг 6: Настройка переменных окружения...${NC}"
# Добавляем Go в PATH
export PATH=$PATH:/usr/local/go/bin

# Настройка GOPATH
mkdir -p "$HOME/go"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

# Добавляем в .bashrc
if ! grep -q '/usr/local/go/bin' "$HOME/.bashrc"; then
    echo '' >> "$HOME/.bashrc"
    echo '# Go language' >> "$HOME/.bashrc"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
    echo 'export GOPATH="$HOME/go"' >> "$HOME/.bashrc"
    echo 'export GOBIN="$GOPATH/bin"' >> "$HOME/.bashrc"
    echo 'export PATH=$PATH:$GOBIN' >> "$HOME/.bashrc"
fi

# Добавляем в .profile
if ! grep -q '/usr/local/go/bin' "$HOME/.profile"; then
    echo '' >> "$HOME/.profile"
    echo '# Go language' >> "$HOME/.profile"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.profile"
    echo 'export GOPATH="$HOME/go"' >> "$HOME/.profile"
    echo 'export GOBIN="$GOPATH/bin"' >> "$HOME/.profile"
    echo 'export PATH=$PATH:$GOBIN' >> "$HOME/.profile"
fi

echo -e "${YELLOW}Шаг 7: Установка полезных Go инструментов...${NC}"
# Создаем структуру директорий
mkdir -p "$HOME/go"/{bin,src,pkg}

# Устанавливаем популярные инструменты
/usr/local/go/bin/go install golang.org/x/tools/cmd/goimports@latest
/usr/local/go/bin/go install golang.org/x/tools/cmd/godoc@latest
/usr/local/go/bin/go install golang.org/x/tools/cmd/gofmt@latest
/usr/local/go/bin/go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
/usr/local/go/bin/go install github.com/air-verse/air@latest

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка завершена!          ${NC}"
echo -e "${GREEN}======================================${NC}"

# Проверка версий
echo -e "${BLUE}Установленные версии:${NC}"
/usr/local/go/bin/go version

echo -e "${YELLOW}Важно!${NC}"
echo -e "${YELLOW}Для использования Go в новых терминалах выполните:${NC}"
echo -e "${BLUE}source ~/.bashrc${NC}"
echo -e "${YELLOW}или перезапустите терминал${NC}"
