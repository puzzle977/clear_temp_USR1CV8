# Путь к папке для очистки
$folderPath = "D:\Users\USR1CV8\AppData\Local\Temp"

# Проверка существования папки
if (-not (Test-Path $folderPath)) {
    Write-Host "Папка $folderPath не найдена!" -ForegroundColor Red
    $logMessage = "$(Get-Date): Папка $folderPath не найдена!"
    Add-Content -Path "C:\Logs\ClearTempLog.txt" -Value $logMessage
    exit
}

# Счетчики для статистики
$filesCount = 0
$foldersCount = 0
$errorsCount = 0
$errorDetails = @()

# Функция для удаления файлов и папок старше 1 дня
function Remove-OldItems {
    param([string]$Path)
    
    try {
        # Удаление файлов старше 1 дня
        $files = Get-ChildItem -Path $Path -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) }
        foreach ($file in $files) {
            try {
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                $script:filesCount++
                Write-Host "Удален файл: $($file.FullName)" -ForegroundColor Green
            }
            catch {
                $script:errorsCount++
                $script:errorDetails += "$(Get-Date): Ошибка удаления файла $($file.FullName) - $($_.Exception.Message)"
                Write-Host "Ошибка удаления файла: $($file.FullName)" -ForegroundColor Red
            }
        }
        
        # Удаление папок старше 1 дня (рекурсивно)
        $folders = Get-ChildItem -Path $Path -Directory | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) }
        foreach ($folder in $folders) {
            try {
                Remove-Item -Path $folder.FullName -Force -Recurse -ErrorAction Stop
                $script:foldersCount++
                Write-Host "Удалена папка: $($folder.FullName)" -ForegroundColor Yellow
            }
            catch {
                $script:errorsCount++
                $script:errorDetails += "$(Get-Date): Ошибка удаления папки $($folder.FullName) - $($_.Exception.Message)"
                Write-Host "Ошибка удаления папки: $($folder.FullName)" -ForegroundColor Red
                
                # Если не удалось удалить папку целиком, пытаемся очистить ее содержимое
                try {
                    Write-Host "Попытка очистки содержимого папки: $($folder.FullName)" -ForegroundColor Magenta
                    Remove-OldItems -Path $folder.FullName
                }
                catch {
                    $script:errorDetails += "$(Get-Date): Ошибка очистки папки $($folder.FullName) - $($_.Exception.Message)"
                }
            }
        }
    }
    catch {
        $script:errorsCount++
        $script:errorDetails += "$(Get-Date): Общая ошибка в пути $Path - $($_.Exception.Message)"
    }
}

# Запуск очистки
Write-Host "Начало очистки папки: $folderPath" -ForegroundColor Cyan
Write-Host "Время: $(Get-Date)" -ForegroundColor Cyan
Write-Host "=" * 50

Remove-OldItems -Path $folderPath

# Логирование
$logPath = "C:\Logs\ClearTempLog.txt"
if (-not (Test-Path "C:\Logs")) { 
    New-Item -ItemType Directory -Path "C:\Logs" -Force 
}

$logMessage = "$(Get-Date): Очистка папки $folderPath. Удалено файлов: $filesCount, папок: $foldersCount, ошибок: $errorsCount"
Add-Content -Path $logPath -Value $logMessage

# Добавление деталей ошибок в лог
if ($errorsCount -gt 0) {
    Add-Content -Path $logPath -Value "Детали ошибок:"
    $errorDetails | ForEach-Object { Add-Content -Path $logPath -Value $_ }
}

# Вывод результатов
Write-Host "=" * 50
Write-Host "Очистка завершена!" -ForegroundColor Cyan
Write-Host "Удалено файлов: $filesCount" -ForegroundColor Green
Write-Host "Удалено папок: $foldersCount" -ForegroundColor Yellow
Write-Host "Ошибок: $errorsCount" -ForegroundColor $(if ($errorsCount -gt 0) { "Red" } else { "Green" })
Write-Host "Всего удалено объектов: $($filesCount + $foldersCount)" -ForegroundColor Cyan

if ($errorsCount -gt 0) {
    Write-Host "Некоторые файлы/папки не были удалены. Проверьте лог для деталей." -ForegroundColor Red
}
