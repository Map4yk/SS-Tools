Write-Host ""
Write-Host "Turning off screen recording:" -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green
$obsProcess = Get-Process -Name "obs64", "obs32", "obs", "ayugram", "telegram", "nvcontainer", "gamebar", "wallpaper32", "wallpaper64", "steam", "discord" -ErrorAction SilentlyContinue

if ($obsProcess) {
    Write-Host "A recording process has been found. Ending..." -ForegroundColor Yellow
    $obsProcess | Stop-Process -Force
    Write-Host "The process has been completed successfully" -ForegroundColor Green
}

Write-Host ""
Write-Host "TCP connections on port 2556:" -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

try {
    $netstatResult = netstat -an | Select-String "2556" | Select-String "TCP"
    if ($netstatResult) {
        $netstatResult
    } else {
        Write-Host "No TCP connections on port 2556" -ForegroundColor Gray
    }
}
catch {
    Write-Host "Error during execution netstat: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "DNS settings:" -ForegroundColor Green
Write-Host "-------------" -ForegroundColor Green

# Выполняем ipconfig для получения DNS информации
try {
    $dnsResult = ipconfig /all | Select-String "DNS"
    if ($dnsResult) {
        $dnsResult
    } else {
        Write-Host "DNS settings were not found" -ForegroundColor Gray
    }
}
catch {
    Write-Host "Error when executing ipconfig: $($_.Exception.Message)" -ForegroundColor Red
}

# InjGen
Write-Host ""
Write-Host "InjGen:" -ForegroundColor Green
Write-Host "-------------" -ForegroundColor Green
iwr "https://github.com/NotRequiem/InjGen/releases/download/v2.0/InjGen.exe" -OutFile "InjGen.exe"
.\InjGen.exe
del InjGen.exe

# JAVAV
$javaProcesses = Get-Process javaw -ErrorAction SilentlyContinue

if (-not $javaProcesses) {
    Write-Host "Процессы javaw.exe не найдены!" -ForegroundColor Red
    Write-Host "Убедитесь, что Minecraft запущен." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Processes found javaw.exe:" -ForegroundColor Green
Write-Host "-------------" -ForegroundColor Green

foreach ($javaProcess in $javaProcesses) {
    $process = Get-Process -Id $javaProcess.Id | ForEach-Object { $_.Modules } | Where-Object { $_.ModuleName -like "*.dll" } | Select-Object FileName -ErrorAction SilentlyContinue

    foreach($dll in $process) {
        if (-not $dll.FileVersionInfo.FileDescription) {
            $signature = Get-AuthenticodeSignature $dll.FileName
            if ($signature.Status -ne 'Valid') {
                if ($dll.FileName -match "natives" -or $dll.FileName -match "Temp" -or $dll.FileName -match "java-runtime-delta") {
                    continue
                }
                Write-Host "Suspicious DLL: $($dll.FileName)" -ForegroundColor Yellow
            }
        }
    }
}


# fsutil delete journal
Write-Host ""
Write-Host "Event-Log fsutil:" -ForegroundColor Green
Write-Host "-------------" -ForegroundColor Green
try {
    $query = @"
<QueryList>
  <Query Id="0" Path="Microsoft-Windows-Ntfs/Operational">
    <Select Path="Microsoft-Windows-Ntfs/Operational">
      *[System[EventID=501]]
      and
      *[EventData[Data[@Name='ProcessName'] and (Data='fsutil.exe')]]
    </Select>
  </Query>
</QueryList>
"@

    $events = Get-WinEvent -FilterXml $query -ErrorAction Stop

    foreach ($event in $events) {
        Write-Host "=== Event ID 501 ===" -ForegroundColor Yellow
        Write-Host "Time: $($event.TimeCreated)" -ForegroundColor Yellow

        # Парсим детали события из XML
        $xml = [xml]$event.ToXml()
        Write-Host $event.Message
        Write-Host "----------------------------------------`n"
    }

    if ($events.Count -eq 0) {
        Write-Host "No 501 events were found with the fsutil.exe process" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "The Microsoft-Windows-Ntfs/Operational log may not be available" -ForegroundColor Red
}


# ServiseCheck
Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/Map4yk/SS-Tools/refs/heads/master/recode/ServiceCheck.ps1)
