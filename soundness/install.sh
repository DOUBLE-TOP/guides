echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-30 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
source ~/.profile
echo "-----------------------------------------------------------------------------"
echo "Установка CLI"
echo "-----------------------------------------------------------------------------"
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash
sleep 1
source ~/.bashrc
sleep 3
soundnessup install
echo "Soundnessup CLI установлен"

echo "Генерирую пару ключей | В процессе Вас попросят ввести пароль. Запомните его"
sleep 3
soundness-cli generate-key --name my-key
sleep 3
echo "Ключи сгенерированы, сохраните мнемоническую фразу"

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
