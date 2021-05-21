$rootSourceFolder = 's:\' # Zu überwachendes Verzeichnis.
$rootDestinationFolder ='T:\' #Stammpfad für das Ziel
#$filter = '*.*'  # Filtermöglichkeiten für Dateien.
$logPath = 'C:\Skripte\' # Pfad für die Logdatei

$logFile= 'RoboCopyLog_'+(Get-Date -Format "yyyyMMdd-HHmm")+'.txt'
$currentYear = Get-Date -Format "yyyy"
$currentDay = Get-Date -Format "yyyyMMdd"
$destinationFolder = $rootDestinationFolder+$currentYear+'\'

if ((Get-ChildItem -Path $rootDestinationFolder -Name "$currentYear") -eq $currentYear){
    robocopy $rootSourceFolder $destinationFolder /XO /MAXAGE:$currentDay /LOG:$logPath$logFile
    }
    else{
    New-Item -path "$destinationFolder" -ItemType Directory
    robocopy $rootSourceFolder $destinationFolder /XO /MAXAGE:$currentDay /LOG:$logPath$logFile
    }
Get-ChildItem -path $logPath*.txt | Where-Object LastWriteTime -lt (Get-Date).AddDays(-30) | Remove-Item