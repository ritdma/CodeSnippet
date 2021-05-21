# Windows Defender Auswertung
# Niklas Zistler 07.05.2020
# Version: 1.0
# Letzte Änderung durch: Niklas Zistler

#Variablen
$DefenderScheduleDay
$DefenderScheduleDayStatus
$NetworkScan
$NetworkScanStatus
$AVStatus
$AVSignatureVersion
$AVSignatureVersionLastUpdate
$AVSignatureLastUpdateInDays
$AntiMalewareClientVersion
$QuarantinedItems

#Script

# Nachfolgend ein Skript von "Jayowend" zum automatischen Ausfuehren als Administrator (https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell):
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }


######Configuration Status of the Windows Defender
#Scheduale Scan Day
$DefenderScheduleDayStatus = (Get-MpPreference).ScanScheduleDay
switch ($DefenderScheduleDayStatus) {
    0 {$DefenderScheduleDay = "Täglich"}
    1 {$DefenderScheduleDay = "Sonntag"}
    2 {$DefenderScheduleDay = "Montag"}
    4 {$DefenderScheduleDay = "Dienstag"}
    5 {$DefenderScheduleDay = "Mittwoch"}
    6 {$DefenderScheduleDay = "Donnerstag"}
    7 {$DefenderScheduleDay = "Freitag"}
    8 {$DefenderScheduleDay = "Samstag"}
    9 {$DefenderScheduleDay = "Nie"}
    Default {$DefenderScheduleDayStatus = ""}
}

#Status Netzwerkscan
$NetworkScanStatus = (Get-MpPreference).EnableNetworkProtection
switch ($NetworkScanStatus){
    0 {$NetworkScan = "Ja"}
    1 {$NetworkScan = "Nein"}
    2 {$NetworkScan = "Überwachung"}
    Default {$NetworkScan = ""}
}
if (($NetworkScan -eq "aus") -and ((Get-MpPreference).DisableScanningMappedNetworkDrivesForFullScan -eq "True")){
    $NetworkScan = "Aus"
}
elseif(($NetworkScan -eq "aus") -and ((Get-MpPreference).DisableScanningMappedNetworkDrivesForFullScan -eq "False")){
    Write-Host -ForegroundColor Red "Die Netzwerk Protection ist aus und das Scannen von Netzlaufwerken ist eingeschaltet!"
}
elseif(($NetworkScan -eq "ein") -and ((Get-MpPreference).DisableScanningMappedNetworkDrivesForFullScan -eq "True")){
    Write-Host -ForegroundColor Red "Die Netzwerk Protection ist eingeschalten und das Scannen von Netzlaufwerken ist aus!"
}
elseif(($NetworkScan -eq "ein") -and ((Get-MpPreference).DisableScanningMappedNetworkDrivesForFullScan -eq "False")){
    Write-Host -ForegroundColor Red "Die Netzwerk Protection und das Scannen von Netzlaufwerken ist eingeschaltet!"
}


#######Information about signature versions, last update, last scan, and more.
### AV Status
if((Get-MpComputerStatus).AMServiceEnabled -eq "True" -and (Get-MpComputerStatus).AntispywareEnabled -eq "True" -and (Get-MpComputerStatus).BehaviorMonitorEnabled -eq "True"-and
        (Get-MpComputerStatus).AntivirusEnabled -eq "True" -and (Get-MpComputerStatus).OnAccessProtectionEnabled -eq "True" -and (Get-MpComputerStatus).RealTimeProtectionEnabled -eq"True"){
    $AVStatus = "Ja"
}
else{
    Write-Host -ForegroundColor Red "Mindestens eines der relevanten Module ist aus!"
    $AVStatus = "Nein"
}

### Signatur Version und Alter
$AVSignatureVersion =  (Get-MpComputerStatus).AntivirusSignatureVersion
$AVSignatureVersionLastUpdate = (Get-MpComputerStatus).AntispywareSignatureLastUpdated
$AVSignatureLastUpdateInDays = (Get-MpComputerStatus).AntivirusSignatureAge
$AntiMalewareClientVersion = (Get-MpComputerStatus).AMProductVersion

### Quarantaene
$QuarantinedItems = ( Get-ChildItem "C:\ProgramData\Microsoft\Windows Defender\Quarantine" | Measure-Object ).Count + ( Get-ChildItem "C:\ProgramData\Microsoft\Windows Defender\LocalCopy" | Measure-Object ).Count

####Ausgabe
Write-Host -ForegroundColor Yellow "Status des Windows Defenders"
Write-Host -ForegroundColor Green "Virenschutz ein? :" $AVStatus
Write-Host -ForegroundColor Green "Netzwerkbedrohungsschutz aus? :" $NetworkScan
Write-Host -ForegroundColor Green "Versionsstand der Software: " $AntiMalewareClientVersion
Write-Host -ForegroundColor Green "Letztes Definitionsupdate: " $AVSignatureVersionLastUpdate
Write-Host -ForegroundColor Green "Alter der Definitionen in Tagen: " $AVSignatureLastUpdateInDays
Write-Host -ForegroundColor Green "Anzahl der Elemente in der Quarantäne: " $QuarantinedItems
Write-Host -ForegroundColor Green "Häufigkeit geplanter Scans: " $DefenderScheduleDay


####Skript Ende
Write-Host -NoNewLine "Beliebige Taste zum Beenden druecken";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");