#!/bin/bash

# Выходим немедленно, если какая-либо команда завершается с ненулевым статусом.
set -e

echo "🚀 Начинаем развертывание Telegram-бота в /home..."

# --- Обновление системы ---
# echo "📦 Обновляем системные пакеты..."
# sudo apt update && sudo apt upgrade -y

# --- Проверка обновления ядра (информационно) ---
# Эта часть предназначена только для информации из исходного лога.
# Перезагрузка рекомендуется после обновления ядра, но не принудительно, чтобы не прерывать скрипт.
# if grep -q "Pending kernel upgrade!" <<< "$(/usr/lib/update-notifier/apt-check --human-readable)"; then
#     echo "⚠️ Обнаружено обновление ядра. Рекомендуется перезагрузить систему после этого развертывания, чтобы применить новое ядро."
#     echo "   Текущее ядро: $(uname -r)"
#     echo "   Ожидаемое ядро после перезагрузки: $(apt list --installed | grep linux-image | head -n 1 | awk '{print $1}') (может быть другим)"
# fi

# # --- Установка зависимостей ---
# echo "🐍 Устанавливаем Python и необходимые инструменты..."
# # python-is-python3 гарантирует, что команда 'python' указывает на python3
# sudo apt install -y python3 python3-pip python3-venv git python-is-python3 build-essential

# --- Подготовка корневой директории бота ---
echo "📁 Подготавливаем корневую директорию бота (/home)..."
# Определяем корневую директорию бота как /home
BOT_DIR="/home/SP"

# Переходим в директорию /home
cd "$BOT_DIR" || { echo "ОШИБКА: Не удалось перейти в директорию $BOT_DIR. Выход."; exit 1; }

echo "   Убедитесь, что все файлы бота (main.py, requirements.txt, telegram-bot.service и т.д.) находятся непосредственно в $BOT_DIR."

# --- Настройка виртуального окружения ---
echo "🔧 Настраиваем виртуальное окружение в $BOT_DIR/venv..."
# Проверяем, существует ли venv, и пересоздаем его, если нужно
if [ -d "venv" ]; then
    echo "   Обнаружено существующее виртуальное окружение. Удаляем и пересоздаем..."
    rm -rf venv
fi
python3 -m venv venv
source venv/bin/activate

# --- Установка зависимостей Python ---
echo "📚 Устанавливаем зависимости Python из requirements.txt..."
# Обновляем pip внутри виртуального окружения
pip install --upgrade pip

# Проверяем, существует ли requirements.txt, прежде чем пытаться установить
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "ОШИБКА: Файл requirements.txt не найден в $BOT_DIR. Убедитесь, что он существует."
    deactivate # Выходим из виртуального окружения
    exit 1
fi

# --- Создание необходимых директорий ---
echo "📂 Создаем необходимые директории (databases, sessions, logs) в $BOT_DIR..."
mkdir -p databases sessions logs

# --- Установка прав доступа и владельца ---
echo "🔐 Устанавливаем права доступа и владельца..."
# Предполагаем, что main.py является исполняемой точкой входа бота
if [ -f "main.py" ]; then
    chmod +x main.py
else
    echo "ПРЕДУПРЕЖДЕНИЕ: main.py не найден. Пропускаем установку прав на исполнение для main.py."
fi

# Изменяем владельца директории бота на пользователя 'root'
BOT_USER="root"
if id "$BOT_USER" &>/dev/null; then
    echo "   Изменяем владельца $BOT_DIR на $BOT_USER:$BOT_USER..."
    chown -R "$BOT_USER":"$BOT_USER" "$BOT_DIR"
else
    echo "ПРЕДУПРЕЖДЕНИЕ: Пользователь '$BOT_USER' не существует. Пропускаем изменение владельца. Файлы останутся принадлежать $(whoami)."
    echo "         Рассмотрите возможность изменения владельца вручную, если вы не запускаете скрипт от имени предполагаемого пользователя."
fi

# --- Настройка службы Systemd ---
echo "⚙️ Настраиваем службу systemd для автозапуска..."
SERVICE_FILE="telegram-bot.service"
if [ -f "$SERVICE_FILE" ]; then
    sudo cp "$SERVICE_FILE" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_FILE"
    echo "   Служба systemd '$SERVICE_FILE' включена. Она будет запускаться при загрузке."
else
    echo "ОШИБКА: Файл службы systemd '$SERVICE_FILE' не найден в $BOT_DIR. Автозапуск не будет настроен."
    echo "       Пожалуйста, убедитесь, что '$SERVICE_FILE' присутствует, если вы хотите использовать systemd."
    exit 1
fi

# Деактивируем виртуальное окружение
deactivate

echo "✅ Развертывание завершено!"
echo ""
echo "--- Следующие шаги ---"
echo "Для управления вашим ботом используйте следующие команды:"
echo "   Запуск: sudo systemctl start telegram-bot"
echo "   Остановка: sudo systemctl stop telegram-bot"
echo "   Статус: sudo systemctl status telegram-bot"
echo "   Логи: sudo journalctl -u telegram-bot -f"
echo ""
echo "Если вы видели предупреждение об обновлении ядра, пожалуйста, рассмотрите возможность перезагрузки сервера:"
echo "   sudo reboot"
echo ""
echo "Для ручной проверки вашего бота (если systemd не запустился или для отладки):"
echo "   cd $BOT_DIR"
echo "   source venv/bin/activate"
echo "   python3 main.py"
echo "   deactivate"