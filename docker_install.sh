#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Сброс цвета

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Установка Docker и Docker Compose  ${NC}"  
echo -e "${BLUE}          на Ubuntu                   ${NC}"
echo -e "${BLUE}======================================${NC}"

# Проверка прав root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Не запускайте скрипт от имени root!${NC}"
   echo -e "${YELLOW}Используйте: bash install_docker.sh${NC}"
   exit 1
fi

# Проверка Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo -e "${RED}Этот скрипт предназначен для Ubuntu${NC}"
    exit 1
fi

echo -e "${YELLOW}Шаг 1: Обновление системы...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${YELLOW}Шаг 2: Удаление старых версий Docker...${NC}"
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null  true

echo -e "${YELLOW}Шаг 3: Установка зависимостей...${NC}"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    lsb-release

echo -e "${YELLOW}Шаг 4: Добавление GPG ключа Docker...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo -e "${YELLOW}Шаг 5: Добавление репозитория Docker...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "${YELLOW}Шаг 6: Обновление индекса пакетов...${NC}"
sudo apt-get update

echo -e "${YELLOW}Шаг 7: Установка Docker...${NC}"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${YELLOW}Шаг 8: Запуск и включение Docker сервиса...${NC}"
sudo systemctl start docker
sudo systemctl enable docker

echo -e "${YELLOW}Шаг 9: Добавление пользователя в группу docker...${NC}"
sudo usermod -aG docker $USER

echo -e "${YELLOW}Шаг 10: Создание символической ссылки для docker-compose...${NC}"
# Для обратной совместимости создаем ссылку на docker compose
sudo ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose 2>/dev/null  true

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}        Установка завершена!          ${NC}"
echo -e "${GREEN}======================================${NC}"

# Проверка версий
echo -e "${BLUE}Установленные версии:${NC}"
docker --version
docker compose version

echo -e "${YELLOW}Важно!${NC}"
echo -e "${YELLOW}Для использования Docker без sudo выполните:${NC}"
echo -e "${BLUE}newgrp docker${NC}"
echo -e "${YELLOW}или перезайдите в систему${NC}"
