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

# Функция для проверки успешности команд
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Команда $1 не найдена!${NC}"
        return 1
    fi
    return 0
}

# Функция для безопасного выполнения команд
safe_run() {
    if ! "$@"; then
        echo -e "${RED}Ошибка выполнения: $*${NC}"
        exit 1
    fi
}

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}    Установка C++ компилятора         ${NC}"
echo -e "${BLUE}    (GCC/G++ + инструменты)           ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
    echo -e "${YELLOW}Используйте: bash main.sh${NC}"
    exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

echo -e "${YELLOW}Шаг 1: Обновление системы...${NC}"
safe_run sudo apt update && safe_run sudo apt upgrade -y

echo -e "${YELLOW}Шаг 2: Установка базовых инструментов разработки...${NC}"
safe_run sudo apt install -y \
    build-essential \
    gcc \
    g++ \
    gdb \
    make \
    cmake \
    automake \
    autotools-dev \
    pkg-config \
    libtool \
    wget \
    curl \
    git \
    vim

echo -e "${YELLOW}Шаг 3: Установка дополнительных библиотек...${NC}"
safe_run sudo apt install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    libffi-dev

echo -e "${YELLOW}Шаг 4: Установка современных версий компиляторов...${NC}"
# Добавляем PPA для последних версий GCC
safe_run sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
safe_run sudo apt update

# Устанавливаем несколько версий GCC/G++
safe_run sudo apt install -y \
    gcc-11 g++-11 \
    gcc-12 g++-12 \
    gcc-13 g++-13

# Настраиваем альтернативы для переключения между версиями
safe_run sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11
safe_run sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 70 --slave /usr/bin/g++ g++ /usr/bin/g++-12
safe_run sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 80 --slave /usr/bin/g++ g++ /usr/bin/g++-13

echo -e "${YELLOW}Шаг 5: Установка инструментов отладки и профилирования...${NC}"
safe_run sudo apt install -y \
    gdb \
    valgrind \
    strace \
    ltrace \
    ddd \
    cgdb

echo -e "${YELLOW}Шаг 6: Установка систем сборки...${NC}"
safe_run sudo apt install -y \
    cmake \
    ninja-build \
    meson

echo -e "${YELLOW}Шаг 7: Установка популярных C++ библиотек...${NC}"
safe_run sudo apt install -y \
    libboost-all-dev \
    libeigen3-dev \
    libgtest-dev \
    libgmock-dev \
    libfmt-dev \
    nlohmann-json3-dev

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка C++ завершена!      ${NC}"
echo -e "${GREEN}======================================${NC}"

# Проверка версий
echo -e "${BLUE}Установленные версии:${NC}"
gcc --version | head -1
g++ --version | head -1
make --version | head -1
cmake --version | head -1
gdb --version | head -1

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}      Установка Rust на Ubuntu        ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка существующей установки Rust
if command -v rustc &> /dev/null; then
    echo -e "${YELLOW}Rust уже установлен:${NC}"
    rustc --version
    cargo --version
    echo -e "${CYAN}Хотите переустановить Rust? (y/n):${NC}"
    read -r reinstall
    if [[ $reinstall != "y" && $reinstall != "Y" ]]; then
        echo -e "${GREEN}Установка Rust отменена${NC}"
    else
        echo -e "${YELLOW}Удаляем существующую установку...${NC}"
        rustup self uninstall -y 2>/dev/null || true
    fi
fi

if [[ $reinstall == "y" || $reinstall == "Y" ]] || ! command -v rustc &> /dev/null; then
    echo -e "${YELLOW}Шаг 1: Установка зависимостей для Rust...${NC}"
    safe_run sudo apt install -y \
        curl \
        build-essential \
        gcc \
        make \
        libc6-dev \
        pkg-config \
        libssl-dev \
        git \
        vim \
        ca-certificates

    echo -e "${YELLOW}Шаг 2: Проверка наличия curl...${NC}"
    if ! check_command curl; then
        echo -e "${RED}curl не установлен. Устанавливаем...${NC}"
        safe_run sudo apt install -y curl
    fi

    echo -e "${YELLOW}Шаг 3: Загрузка и запуск установщика Rust...${NC}"

    # Функция для тихой установки Rust
    install_rust_quietly() {
        if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
            echo -e "${RED}Ошибка установки Rust${NC}"
            exit 1
        fi
    }

    # Функция для интерактивной установки Rust
    install_rust_interactively() {
        if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; then
            echo -e "${RED}Ошибка установки Rust${NC}"
            exit 1
        fi
    }

    echo -e "${CYAN}Выберите режим установки:${NC}"
    echo -e "${PURPLE}1)${NC} Автоматическая установка (рекомендуется)"
    echo -e "${PURPLE}2)${NC} Интерактивная установка (для опытных пользователей)"
    echo -e "${CYAN}Ваш выбор (1 или 2):${NC}"
    read -r choice

    case $choice in
        1)
            echo -e "${YELLOW}Выполняется автоматическая установка...${NC}"
            install_rust_quietly
            ;;
        2)
            echo -e "${YELLOW}Запускается интерактивная установка...${NC}"
            install_rust_interactively
            ;;
        *)
            echo -e "${YELLOW}Неверный выбор. Выполняется автоматическая установка...${NC}"
            install_rust_quietly
            ;;
    esac

    echo -e "${YELLOW}Шаг 4: Настройка переменных окружения...${NC}"
    source "$HOME/.cargo/env"

    # Добавляем Rust в PATH для текущей сессии
    if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # Проверяем, добавлен ли путь в .bashrc
    if ! grep -q '.cargo/env' "$HOME/.bashrc"; then
        echo 'source "$HOME/.cargo/env"' >> "$HOME/.bashrc"
    fi

    # Проверяем, добавлен ли путь в .profile
    if ! grep -q '.cargo/env' "$HOME/.profile"; then
        echo 'source "$HOME/.cargo/env"' >> "$HOME/.profile"
    fi

    echo -e "${YELLOW}Шаг 5: Обновление Rust до последней версии...${NC}"
    rustup update

    echo -e "${YELLOW}Шаг 6: Установка дополнительных компонентов...${NC}"
    rustup component add \
        rust-src \
        rust-analysis \
        rustfmt \
        clippy \
        rust-docs

    echo -e "${YELLOW}Шаг 7: Настройка инструментов разработки...${NC}"
    # Установка полезных инструментов через cargo
    cargo install \
        cargo-edit \
        cargo-watch \
        cargo-tree \
        cargo-outdated

    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}        Установка Rust завершена!     ${NC}"
    echo -e "${GREEN}======================================${NC}"

    # Проверка версий
    echo -e "${BLUE}Установленные версии:${NC}"
    rustc --version
    cargo --version
    rustup --version

    echo -e "${BLUE}Установленные компоненты:${NC}"
    rustup component list --installed

    echo -e "${BLUE}Установленные цепочки инструментов:${NC}"
    rustup toolchain list

    echo -e "${YELLOW}Важно!${NC}"
    echo -e "${YELLOW}Для использования Rust в новых терминалах выполните:${NC}"
    echo -e "${BLUE}source ~/.cargo/env${NC}"
    echo -e "${YELLOW}или перезапустите терминал${NC}"

    # Проверка переменных окружения
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}  Проверка переменных окружения:     ${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo -e "${YELLOW}RUSTUP_HOME:${NC} ${RUSTUP_HOME:-$HOME/.rustup}"
    echo -e "${YELLOW}CARGO_HOME:${NC} ${CARGO_HOME:-$HOME/.cargo}"
    echo -e "${YELLOW}PATH содержит Rust:${NC}"
    if [[ ":$PATH:" == *":$HOME/.cargo/bin:"* ]]; then
        echo -e "${GREEN}✓ Да${NC}"
    else
        echo -e "${RED}✗ Нет, добавьте: export PATH=\"\$HOME/.cargo/bin:\$PATH\"${NC}"
    fi
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Установка Docker и Docker Compose  ${NC}"
echo -e "${BLUE}           на Ubuntu                   ${NC}"
echo -e "${BLUE}======================================${NC}"

echo -e "${YELLOW}Шаг 1: Обновление системы...${NC}"
safe_run sudo apt update && safe_run sudo apt upgrade -y

echo -e "${YELLOW}Шаг 2: Удаление старых версий Docker...${NC}"
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

echo -e "${YELLOW}Шаг 3: Установка зависимостей...${NC}"
safe_run sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    lsb-release

echo -e "${YELLOW}Шаг 4: Добавление GPG ключа Docker...${NC}"
safe_run sudo install -m 0755 -d /etc/apt/keyrings
if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
    echo -e "${RED}Ошибка загрузки GPG ключа Docker${NC}"
    exit 1
fi
safe_run sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo -e "${YELLOW}Шаг 5: Добавление репозитория Docker...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "${YELLOW}Шаг 6: Обновление индекса пакетов...${NC}"
safe_run sudo apt-get update

echo -e "${YELLOW}Шаг 7: Установка Docker...${NC}"
safe_run sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${YELLOW}Шаг 8: Запуск и включение Docker сервиса...${NC}"
safe_run sudo systemctl start docker
safe_run sudo systemctl enable docker

echo -e "${YELLOW}Шаг 9: Добавление пользователя в группу docker...${NC}"
safe_run sudo usermod -aG docker $USER

echo -e "${YELLOW}Шаг 10: Создание символической ссылки для docker-compose...${NC}"
# Для обратной совместимости создаем ссылку на docker compose
sudo ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose 2>/dev/null || true

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка Docker завершена!   ${NC}"
echo -e "${GREEN}======================================${NC}"

# Проверка версий
echo -e "${BLUE}Установленные версии:${NC}"
docker --version
docker compose version

echo -e "${YELLOW}Важно!${NC}"
echo -e "${YELLOW}Для использования Docker без sudo выполните:${NC}"
echo -e "${BLUE}newgrp docker${NC}"
echo -e "${YELLOW}или перезайдите в систему${NC}"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}        Установка Go (Golang)         ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка существующей установки
if command -v go &> /dev/null; then
    echo -e "${YELLOW}Go уже установлен:${NC}"
    go version
    echo -e "${CYAN}Хотите переустановить Go? (y/n):${NC}"
    read -r reinstall_go
    if [[ $reinstall_go != "y" && $reinstall_go != "Y" ]]; then
        echo -e "${GREEN}Установка Go отменена${NC}"
    else
        echo -e "${YELLOW}Удаляем существующую установку...${NC}"
        sudo rm -rf /usr/local/go
    fi
fi

if [[ $reinstall_go == "y" || $reinstall_go == "Y" ]] || ! command -v go &> /dev/null; then
    echo -e "${YELLOW}Шаг 1: Установка зависимостей...${NC}"
    safe_run sudo apt install -y \
        wget \
        curl \
        git \
        build-essential \
        ca-certificates

    echo -e "${YELLOW}Шаг 2: Определение последней версии Go...${NC}"
    # Получаем последнюю версию Go
    LATEST_VERSION=$(curl -s https://api.github.com/repos/golang/go/releases/latest | grep '"tag_name":' | sed -E 's/.*"go([^"]+)".*/\1/' || echo "")
    if [ -z "$LATEST_VERSION" ]; then
        LATEST_VERSION="1.22.6"  # Fallback версия
        echo -e "${YELLOW}Используем fallback версию: ${LATEST_VERSION}${NC}"
    else
        echo -e "${GREEN}Найдена последняя версия: ${LATEST_VERSION}${NC}"
    fi

    echo -e "${YELLOW}Шаг 3: Загрузка Go ${LATEST_VERSION}...${NC}"
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
    if ! wget "https://golang.org/dl/${GO_TAR}"; then
        echo -e "${RED}Ошибка загрузки Go${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Шаг 4: Установка Go...${NC}"
    safe_run sudo tar -C /usr/local -xzf "${GO_TAR}"

    echo -e "${YELLOW}Шаг 5: Настройка переменных окружения...${NC}"
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

    echo -e "${YELLOW}Шаг 6: Установка полезных Go инструментов...${NC}"
    # Создаем структуру директорий
    mkdir -p "$HOME/go"/{bin,src,pkg}

    # Устанавливаем популярные инструменты
    /usr/local/go/bin/go install golang.org/x/tools/cmd/goimports@latest
    /usr/local/go/bin/go install golang.org/x/tools/cmd/godoc@latest
    /usr/local/go/bin/go install golang.org/x/tools/cmd/gofmt@latest
    /usr/local/go/bin/go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    /usr/local/go/bin/go install github.com/air-verse/air@latest

    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}        Установка Go завершена!       ${NC}"
    echo -e "${GREEN}======================================${NC}"

    # Проверка версий
    echo -e "${BLUE}Установленные версии:${NC}"
    /usr/local/go/bin/go version

    echo -e "${YELLOW}Важно!${NC}"
    echo -e "${YELLOW}Для использования Go в новых терминалах выполните:${NC}"
    echo -e "${BLUE}source ~/.bashrc${NC}"
    echo -e "${YELLOW}или перезапустите терминал${NC}"
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}     Установка Telegram Desktop       ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка существующей установки
if command -v telegram-desktop &> /dev/null; then
    echo -e "${YELLOW}Telegram уже установлен${NC}"
    echo -e "${CYAN}Хотите переустановить Telegram? (y/n):${NC}"
    read -r reinstall_tg
    if [[ $reinstall_tg != "y" && $reinstall_tg != "Y" ]]; then
        echo -e "${GREEN}Установка Telegram отменена${NC}"
    fi
fi

if [[ $reinstall_tg == "y" || $reinstall_tg == "Y" ]] || ! command -v telegram-desktop &> /dev/null; then
    echo -e "${CYAN}Выберите метод установки:${NC}"
    echo -e "${PURPLE}1)${NC} Snap (рекомендуется) - автоматические обновления"
    echo -e "${PURPLE}2)${NC} APT - из официальных репозиториев"
    echo -e "${PURPLE}3)${NC} Официальный архив - прямая загрузка"
    echo -e "${CYAN}Ваш выбор (1-3):${NC}"
    read -r tg_choice

    case $tg_choice in
        1)
            echo -e "${YELLOW}Установка через Snap...${NC}"
            
            # Проверяем, установлен ли snapd
            if ! command -v snap &> /dev/null; then
                echo -e "${YELLOW}Устанавливаем snapd...${NC}"
                safe_run sudo apt update
                safe_run sudo apt install -y snapd
            fi
            
            # Устанавливаем Telegram через snap
            safe_run sudo snap install telegram-desktop
            
            echo -e "${GREEN}✓ Telegram установлен через Snap${NC}"
            ;;
            
        2)
            echo -e "${YELLOW}Установка через APT...${NC}"
            
            safe_run sudo apt update
            
            # Проверяем доступность в репозитории
            if apt-cache search telegram-desktop | grep -q telegram-desktop; then
                safe_run sudo apt install -y telegram-desktop
                echo -e "${GREEN}✓ Telegram установлен через APT${NC}"
            else
                echo -e "${YELLOW}Telegram не найден в стандартных репозиториях${NC}"
                echo -e "${YELLOW}Используем Snap...${NC}"
                
                if ! command -v snap &> /dev/null; then
                    safe_run sudo apt install -y snapd
                fi
                safe_run sudo snap install telegram-desktop
                echo -e "${GREEN}✓ Telegram установлен через Snap${NC}"
            fi
            ;;
            
        3)
            echo -e "${YELLOW}Установка официального архива...${NC}"
            
            # Создаем директорию для установки
            INSTALL_DIR="/opt/Telegram"
            safe_run sudo mkdir -p "$INSTALL_DIR"
            
            # Загружаем последнюю версию
            cd /tmp
            echo -e "${YELLOW}Загружаем последнюю версию Telegram...${NC}"
            if ! wget -O telegram.tar.xz "https://telegram.org/dl/desktop/linux"; then
                echo -e "${RED}Ошибка загрузки Telegram${NC}"
                exit 1
            fi
            
            # Извлекаем архив
            tar -xf telegram.tar.xz
            
            # Перемещаем в /opt
            sudo rm -rf "$INSTALL_DIR"
            safe_run sudo mv Telegram "$INSTALL_DIR"
            
            # Создаем символическую ссылку
            safe_run sudo ln -sf "$INSTALL_DIR/Telegram" /usr/local/bin/telegram-desktop
            
            # Создаем desktop файл
            cat > ~/.local/share/applications/telegram-desktop.desktop << 'EOF'
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
                safe_run sudo apt update
                safe_run sudo apt install -y snapd
            fi
            
            safe_run sudo snap install telegram-desktop
            echo -e "${GREEN}✓ Telegram установлен через Snap${NC}"
            ;;
    esac

    echo -e "${YELLOW}Установка дополнительных зависимостей...${NC}"
    safe_run sudo apt update
    safe_run sudo apt install -y \
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
    echo -e "${GREEN}      Установка Telegram завершена!  ${NC}"
    echo -e "${GREEN}======================================${NC}"
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}     Установка Visual Studio Code     ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка существующей установки
if command -v code &> /dev/null; then
    echo -e "${YELLOW}VS Code уже установлен:${NC}"
    code --version | head -1
    echo -e "${CYAN}Хотите переустановить VS Code? (y/n):${NC}"
    read -r reinstall_code
    if [[ $reinstall_code != "y" && $reinstall_code != "Y" ]]; then
        echo -e "${GREEN}Установка VS Code отменена${NC}"
    fi
fi

if [[ $reinstall_code == "y" || $reinstall_code == "Y" ]] || ! command -v code &> /dev/null; then
    echo -e "${CYAN}Выберите метод установки:${NC}"
    echo -e "${PURPLE}1)${NC} Официальный репозиторий Microsoft (рекомендуется)"
    echo -e "${PURPLE}2)${NC} Snap пакет"
    echo -e "${PURPLE}3)${NC} .deb пакет (прямая загрузка)"
    echo -e "${CYAN}Ваш выбор (1-3):${NC}"
    read -r code_choice

    case $code_choice in
        1)
            echo -e "${YELLOW}Установка через официальный репозиторий Microsoft...${NC}"
            
            echo -e "${YELLOW}Шаг 1: Установка зависимостей...${NC}"
            safe_run sudo apt update
            safe_run sudo apt install -y \
                wget \
                gpg \
                apt-transport-https \
                software-properties-common
            
            echo -e "${YELLOW}Шаг 2: Импорт GPG ключа Microsoft...${NC}"
            if ! wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg; then
                echo -e "${RED}Ошибка загрузки GPG ключа Microsoft${NC}"
                exit 1
            fi
            safe_run sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            safe_run sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            
            echo -e "${YELLOW}Шаг 3: Установка VS Code...${NC}"
            safe_run sudo apt update
            safe_run sudo apt install -y code
            
            echo -e "${GREEN}✓ VS Code установлен через официальный репозиторий${NC}"
            ;;
            
        2)
            echo -e "${YELLOW}Установка через Snap...${NC}"
            
            # Проверяем, установлен ли snapd
            if ! command -v snap &> /dev/null; then
                echo -e "${YELLOW}Устанавливаем snapd...${NC}"
                safe_run sudo apt update
                safe_run sudo apt install -y snapd
            fi
            
            # Устанавливаем VS Code через snap
            safe_run sudo snap install --classic code
            
            echo -e "${GREEN}✓ VS Code установлен через Snap${NC}"
            ;;
            
        3)
            echo -e "${YELLOW}Установка .deb пакета...${NC}"
            
            echo -e "${YELLOW}Загружаем .deb пакет...${NC}"
            cd /tmp
            if ! wget -O vscode.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'; then
                echo -e "${RED}Ошибка загрузки VS Code${NC}"
                exit 1
            fi
            
            echo -e "${YELLOW}Устанавливаем пакет...${NC}"
            safe_run sudo apt update
            safe_run sudo apt install -y ./vscode.deb
            
            echo -e "${GREEN}✓ VS Code установлен из .deb пакета${NC}"
            ;;
            
        *)
            echo -e "${RED}Неверный выбор. Используем официальный репозиторий...${NC}"
            # Повторяем установку метода 1
            safe_run sudo apt update
            safe_run sudo apt install -y wget gpg apt-transport-https software-properties-common
            if ! wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg; then
                echo -e "${RED}Ошибка загрузки GPG ключа Microsoft${NC}"
                exit 1
            fi
            safe_run sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            safe_run sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            safe_run sudo apt update
            safe_run sudo apt install -y code
            echo -e "${GREEN}✓ VS Code установлен через официальный репозиторий${NC}"
            ;;
    esac

    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}       Установка VS Code завершена!  ${NC}"
    echo -e "${GREEN}======================================${NC}"
fi

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}         Установка Obsidian           ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка существующей установки
if command -v obsidian &> /dev/null; then
    echo -e "${YELLOW}Obsidian уже установлен${NC}"
    echo -e "${CYAN}Хотите переустановить Obsidian? (y/n):${NC}"
    read -r reinstall_obs
    if [[ $reinstall_obs != "y" && $reinstall_obs != "Y" ]]; then
        echo -e "${GREEN}Установка Obsidian отменена${NC}"
    fi
fi

if [[ $reinstall_obs == "y" || $reinstall_obs == "Y" ]] || ! command -v obsidian &> /dev/null; then
    echo -e "${CYAN}Выберите метод установки:${NC}"
    echo -e "${PURPLE}1)${NC} Snap пакет (рекомендуется)"
    echo -e "${PURPLE}2)${NC} AppImage (официальный)"
    echo -e "${CYAN}Ваш выбор (1-2):${NC}"
    read -r obs_choice

    case $obs_choice in
        1)
            echo -e "${YELLOW}Установка через Snap...${NC}"
            
            # Проверяем, установлен ли snapd
            if ! command -v snap &> /dev/null; then
                echo -e "${YELLOW}Устанавливаем snapd...${NC}"
                safe_run sudo apt update
                safe_run sudo apt install -y snapd
            fi
            
            # Устанавливаем Obsidian через snap
            safe_run sudo snap install obsidian --classic
            
            echo -e "${GREEN}✓ Obsidian установлен через Snap${NC}"
            ;;
            
        2)
            echo -e "${YELLOW}Установка AppImage...${NC}"
            
            echo -e "${YELLOW}Шаг 1: Установка зависимостей...${NC}"
            safe_run sudo apt update
            safe_run sudo apt install -y \
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
            DOWNLOAD_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep "browser_download_url.*AppImage" | grep -v "arm64" | cut -d : -f 2,3 | tr -d \" || echo "")

            if [ -z "$DOWNLOAD_URL" ]; then
                echo -e "${RED}Не удалось получить ссылку на загрузку${NC}"
                exit 1
            fi

            if ! wget "$DOWNLOAD_URL"; then
                echo -e "${RED}Ошибка загрузки Obsidian${NC}"
                exit 1
            fi
            
            APPIMAGE_FILE=$(ls *.AppImage | head -1)

            echo -e "${YELLOW}Шаг 4: Извлечение AppImage...${NC}"
            chmod +x "$APPIMAGE_FILE"
            ./"$APPIMAGE_FILE" --appimage-extract

            echo -e "${YELLOW}Шаг 5: Установка в систему...${NC}"
            sudo rm -rf /opt/Obsidian
            safe_run sudo mv squashfs-root /opt/Obsidian

            echo -e "${YELLOW}Шаг 6: Настройка прав доступа...${NC}"
            safe_run sudo chown -R root: /opt/Obsidian
            safe_run sudo chmod 4755 /opt/Obsidian/chrome-sandbox 2>/dev/null || true
            safe_run sudo find /opt/Obsidian -type d -exec chmod 755 {} \;

            echo -e "${YELLOW}Шаг 7: Создание символической ссылки...${NC}"
            safe_run sudo ln -sf /opt/Obsidian/AppRun /usr/local/bin/obsidian

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

            echo -e "${GREEN}✓ Obsidian установлен как AppImage${NC}"
            ;;
            
        *)
            echo -e "${RED}Неверный выбор. Используем Snap...${NC}"
            
            if ! command -v snap &> /dev/null; then
                safe_run sudo apt update
                safe_run sudo apt install -y snapd
            fi
            
            safe_run sudo snap install obsidian --classic
            echo -e "${GREEN}✓ Obsidian установлен через Snap${NC}"
            ;;
    esac

    echo -e "${YELLOW}Установка дополнительных зависимостей...${NC}"
    safe_run sudo apt install -y \
        fonts-noto \
        fonts-noto-color-emoji \
        fonts-liberation

    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}      Установка Obsidian завершена!  ${NC}"
    echo -e "${GREEN}======================================${NC}"
fi

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}    ВСЕ УСТАНОВКИ ЗАВЕРШЕНЫ!          ${NC}"
echo -e "${GREEN}======================================${NC}"

echo -e "${BLUE}Установленные программы:${NC}"
echo -e "${YELLOW}✓ C++ (GCC/G++)${NC}"
if command -v rustc &> /dev/null; then
    echo -e "${YELLOW}✓ Rust${NC}"
fi
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}✓ Docker${NC}"
fi
if command -v go &> /dev/null; then
    echo -e "${YELLOW}✓ Go${NC}"
fi
if command -v telegram-desktop &> /dev/null || snap list telegram-desktop &> /dev/null 2>&1; then
    echo -e "${YELLOW}✓ Telegram${NC}"
fi
if command -v code &> /dev/null; then
    echo -e "${YELLOW}✓ VS Code${NC}"
fi
if command -v obsidian &> /dev/null || snap list obsidian &> /dev/null 2>&1; then
    echo -e "${YELLOW}✓ Obsidian${NC}"
fi

echo -e "${CYAN}Перезапустите терминал или выполните:${NC}"
echo -e "${BLUE}source ~/.bashrc${NC}"
echo -e "${CYAN}для применения всех изменений PATH${NC}"

echo -e "${GREEN}Готово! Все программы установлены и готовы к использованию! 🎉${NC}"
