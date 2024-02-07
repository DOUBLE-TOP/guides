#!/usr/bin/expect

# Проверяем, передан ли пароль как аргумент
if {$argc < 1} {
    puts "Usage: $argv0 <password>"
    exit 1
}

# Сохраняем переданный пароль в переменную
set password [lindex $argv 0]

# Задайте таймаут ожидания ответа от скрипта
set timeout -1

# Запуск скрипта установки
spawn bash -c "exec bash <(curl -s https://gitlab.com/shardeum/validator/dashboard/-/raw/main/installer.sh)"

proc safe_send {cmd} {
    catch {send "$cmd"}
}

# Ожидание вопросов и автоматический ответ на них
expect "By running this installer, you agree to allow the Shardeum team to collect this data. (Y/n)?:"
safe_send "Y\r"

expect "What base directory should the node use (default ~/.shardeum):"
safe_send "\r"

expect "Do you want to run the web based Dashboard? (Y/n):"
safe_send "Y\r"

expect "Set the password to access the Dashboard:"
safe_send "$password\r"

expect "Enter the port (1025-65536) to access the web based Dashboard (default 8080):"
safe_send "\r"

expect "If you wish to set an explicit external IP, enter an IPv4 address (default=auto):"
safe_send "\r"

expect "If you wish to set an explicit internal IP, enter an IPv4 address (default=auto):"
safe_send "\r"

expect "Enter the first port (1025-65536) for p2p communication (default 9001):"
safe_send "\r"

expect "Enter the second port (1025-65536) for p2p communication (default 10001):"
safe_send "\r"

expect "Do you want to change the password for the Dashboard? (y/N):"
safe_send "N\r"

# Ожидание завершения скрипта
expect eof
