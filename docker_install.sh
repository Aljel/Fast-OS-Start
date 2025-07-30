#!/bin/bash

# Скрипт установки последней стабильной версии Docker Engine и Compose на Ubuntu

set -e

# Обновление индекса пакетов
sudo apt update && sudo apt upgrade -y

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

echo "Docker успешно установлен. Выйдите из системы и войдите снова, чтобы применять группу docker."
docker --version
docker compose version

