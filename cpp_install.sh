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
echo -e "${BLUE}    Установка C++ компилятора         ${NC}"
echo -e "${BLUE}    (GCC/G++ + инструменты)           ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
   echo -e "${YELLOW}Используйте: bash install_cpp.sh${NC}"
   exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

echo -e "${YELLOW}Шаг 1: Обновление системы...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${YELLOW}Шаг 2: Установка базовых инструментов разработки...${NC}"
sudo apt install -y \
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
sudo apt install -y \
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
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
sudo apt update

# Устанавливаем несколько версий GCC/G++
sudo apt install -y \
    gcc-13 g++-13

# Настраиваем альтернативы для переключения между версиями
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 70 --slave /usr/bin/g++ g++ /usr/bin/g++-12
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 80 --slave /usr/bin/g++ g++ /usr/bin/g++-13

echo -e "${YELLOW}Шаг 5: Установка инструментов отладки и профилирования...${NC}"
sudo apt install -y \
    gdb \
    valgrind \
    strace \
    ltrace \
    ddd \
    cgdb

echo -e "${YELLOW}Шаг 6: Установка систем сборки...${NC}"
sudo apt install -y \
    cmake \
    ninja-build \
    meson

echo -e "${YELLOW}Шаг 7: Установка популярных C++ библиотек...${NC}"
sudo apt install -y \
    libboost-all-dev \
    libeigen3-dev \
    libgtest-dev \
    libgmock-dev \
    libfmt-dev \
    nlohmann-json3-dev

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка завершена!          ${NC}"
echo -e "${GREEN}======================================${NC}"

# Проверка версий
echo -e "${BLUE}Установленные версии:${NC}"
gcc --version | head -1
g++ --version | head -1
make --version | head -1
cmake --version | head -1
gdb --version | head -1

