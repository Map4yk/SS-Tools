Clear-Host

Write-Host ""
function Test-Admin {;$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent());$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);}
if (!(Test-Admin)) {
    Write-Warning "Please Run This Script as Admin."
    Start-Sleep 10
    Exit
}

Start-Sleep -s 3

Clear-Host

$host.privatedata.ProgressForegroundColor = "red";
$host.privatedata.ProgressBackgroundColor = "black";

$pathsFilePath = "paths.txt"
if(-Not(Test-Path -Path $pathsFilePath)){
    Write-Warning "The file $pathsFilePath does not exist."
    Start-Sleep 10
    Exit
}

$paths = Get-Content "paths.txt" -Encoding UTF8
$stopwatch = [Diagnostics.Stopwatch]::StartNew()

$results = @()
$count = 0
$totalCount = $paths.Count
$progressID = 1

foreach ($path in $paths) {
    Try {
        
        $zoneid = Get-Content -Path "$path" -Stream zone.identifier -ErrorAction SilentlyContinue

        if ($zoneid.Contains("https://doomsdayclient.com/")) {
            Write-Host "Найден лоадер Doomsday: "$path -ForegroundColor Red
        }

    } Catch {
    }
}



$time = $stopwatch.Elapsed.Hours.ToString("00") + ":" + $stopwatch.Elapsed.Minutes.ToString("00") + ":" + $stopwatch.Elapsed.Seconds.ToString("00") + "." + $stopwatch.Elapsed.Milliseconds.ToString("000")

Write-Host ""
Write-Host "The scan took $time to run." -ForegroundColor Yellow
