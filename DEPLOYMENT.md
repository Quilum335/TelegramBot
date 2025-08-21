
##   L0sCFpVdOiqQ


scp -r C:\Users\root\Pictures\SP root@77.239.105.10:/home/

ssh root@77.239.105.10


#### Запуск автоматического развертывания:
```bash
cd /home/SP
chmod +x deploy.sh
./deploy.sh
```


### Основные команды:
```bash
# Запуск
sudo systemctl start telegram-bot

# Остановка
sudo systemctl stop telegram-bot
rm -rf /home/SP
exit
# Перезапуск
sudo systemctl restart telegram-bot

# Статус
sudo systemctl status telegram-bot

# Автозапуск при загрузке системы
sudo systemctl enable telegram-bot

# Отключение автозапуска
sudo systemctl disable telegram-bot
```

### Просмотр логов:
```bash
# Все логи
sudo journalctl -u telegram-bot

# Логи в реальном времени
sudo journalctl -u telegram-bot -f

# Логи за последний час
sudo journalctl -u telegram-bot --since "1 hour ago"

# Логи за сегодня
sudo journalctl -u telegram-bot --since today
```

## 🔄 Обновление бота
sudo systemctl restart telegram-bot



