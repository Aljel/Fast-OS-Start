#!/bin/bash

# Скрипт установки последней стабильной версии Rust через rustup

set -e

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
