# clear_temp_USR1CV8

Скрипт powershell для очистки папки temp пользователя 1C или любого указанного указанного пути. 


В скрипте $folderPath = "D:\Users\USR1CV8\AppData\Local\Temp" меняем на свой путь. В принципе это может быть любая папка в системе, в которой есть необходимость чистить файлы в определенный промежуток времени или в ручную при запуске скрипта


Для изменения времени меняем 1 на любую нужную цифру раз в день или год в двух местах.
$files = Get-ChildItem -Path $Path -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) }
$folders = Get-ChildItem -Path $Path -Directory | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) }

Если хотим запуск в определенное время автоматически, создаем таск через taskschd.msc
Доюавляем новый таск, создаем триггер. Далее действия, запуск программы и в поле "Программа или сценарий" powershell.exe, в аргументах пишем путь к нашему скрипту -ExecutionPolicy Bypass -File "C:\skript\ClearTempUSR1CV8.ps1.
