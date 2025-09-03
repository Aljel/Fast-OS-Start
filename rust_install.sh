#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Сброс цвета

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}    Установка Rust на Ubuntu          ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
   echo -e "${YELLOW}Используйте: bash install_rust.sh${NC}"
   exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

# Проверка существующей установки Rust
if command -v rustc &> /dev/null; then
    echo -e "${YELLOW}Rust уже установлен:${NC}"
    rustc --version
    cargo --version
    echo -e "${CYAN}Хотите переустановить Rust? (y/n):${NC}"
    read -r reinstall
    if [[ $reinstall != "y" && $reinstall != "Y" ]]; then
        echo -e "${GREEN}Установка отменена${NC}"
        exit 0
    fi
    echo -e "${YELLOW}Удаляем существующую установку...${NC}"
    rustup self uninstall -y 2>/dev/null || true
fi

echo -e "${YELLOW}Шаг 1: Обновление системы...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${YELLOW}Шаг 2: Установка зависимостей...${NC}"
sudo apt install -y \
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

echo -e "${YELLOW}Шаг 3: Проверка наличия curl...${NC}"
if ! command -v curl &> /dev/null; then
    echo -e "${RED}curl не установлен. Устанавливаем...${NC}"
    sudo apt install -y curl
fi

echo -e "${YELLOW}Шаг 4: Загрузка и запуск установщика Rust...${NC}"

# Функция для тихой установки Rust
install_rust_quietly() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

# Функция для интерактивной установки Rust
install_rust_interactively() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
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

echo -e "${YELLOW}Шаг 5: Настройка переменных окружения...${NC}"
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

echo -e "${YELLOW}Шаг 6: Обновление Rust до последней версии...${NC}"
rustup update

echo -e "${YELLOW}Шаг 7: Установка дополнительных компонентов...${NC}"
rustup component add \
    rust-src \
    rust-analysis \
    rls \
    rustfmt \
    clippy \
    rust-docs

echo -e "${YELLOW}Шаг 8: Настройка инструментов разработки...${NC}"
# Установка полезных инструментов через cargo
cargo install \
    cargo-edit \
    cargo-watch \
    cargo-tree \
    cargo-outdated

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка завершена!          ${NC}"
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
