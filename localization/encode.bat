@echo off
set /p id="Enter the file name (excluding extension) - "
w3strings.exe -e csv/%id%.csv -i 2698
ren csv\"%id%.csv.w3strings" "%id%.w3strings"
ren csv\"%id%.csv.w3strings.ws" "%id%.ws"
move csv\%id%.w3strings w3strings\
move csv\%id%.ws ws\
copy w3strings\%id%.w3strings ..\content\
pause