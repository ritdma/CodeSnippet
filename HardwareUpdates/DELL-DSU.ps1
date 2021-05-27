# Skript zum Aktualisieren der Treiber und Firmware von Dell-Servern über DELL EMC System Update (DSU)

# Changelog #
# 27.05.2021 Tobias Nawrocki: Akualisierung auf DSU 1.9.1.0 inkl. Pfadanpassungen; Download der Notification Bridge integriert

# Aktuelle Version manuell eintragen, auf genaue Version achten:
$currentDSUversion = "1.9.1.0"
$downloadDSU = "https://dl.dell.com/FOLDER07144386M/1/Systems-Management_Application_55R7T_WN64_1.9.1.0_A00.EXE"
$downloadNotificationBridge = "https://bitbucket.org/paulcsiki/notification-bridge-plugin/downloads/Notification%20Bridge%201.3.zip"

# Ordnerstruktur anlegen, falls nicht vorhanden
$pathDsuRoot = "C:\ProgramData\Dell\DELL EMC System Update"
$pathDsuProgram = "C:\Program Files\Dell\DELL EMC System Update"
$pathTempDownload = "C:\Temp"
$pathDsuData = "$pathDsuRoot\dell_dup"
$pathDsuLog = "$pathDsuRoot\Log.txt"
$pathDsuLogArchive = "$pathDsuData\Log-Archiv"
$pathNotificationBridge = "C:\Skripte\Pulseway-Addins\NotificationBridge"

If(!(Test-Path $pathDsuLogArchive))
{
      New-Item -ItemType Directory -Force -Path $pathDsuLogArchive
      Write-Host "Ordner für Log-Archiv erstellt." -ForegroundColor Green
}

If(!(Test-Path $pathTempDownload))
{
      New-Item -ItemType Directory -Force -Path $pathTempDownload
      Write-Host "Temp-Ordner erstellt" -ForegroundColor Green
}

# Prüfen, ob Notification Bridge vorhanden ist
$checkNotificationBridge = 
{

    If (Test-Path -Path "$pathNotificationBridge\Notify.exe")
    {   
        Write-Host "Notification Bridge vorhanden" -NoNewline -ForegroundColor Green
    }

    Else 
    {
        # Notification Bridge herunterladen
        Write-Host "Notification Bridge nicht vorhanden, beginne Download"-ForegroundColor Green
        Invoke-WebRequest $downloadNotificationBridge -OutFile "$pathTempDownload\NotificationBridge.zip"
        Start-Sleep -s 10
        Expand-Archive "$pathTempDownload\NotificationBridge.zip" -DestinationPath $pathNotificationBridge
        Rename-Item "$pathNotificationBridge\NotificationBridge.exe" "$pathNotificationBridge\Notify.exe"
        & "$pathNotificationBridge\Notify.exe" -p 0 -t "Notification Bridge heruntergeladen und entpackt"
    }
}  
& $checkNotificationBridge

# Prüfen, ob DSU installiert und aktuell ist
$vorherigerInstallationsversuch = "Nein"
$checkDSU = 
{

    If (Test-Path -Path "$pathDsuProgram\DSU.exe")
    {
        # Aktuelle Version abfragen
        $dsuversion = & "$pathDsuProgram\DSU.exe" --version | Where-Object { $_ -match '^DELL' } | Out-String
        Write-Host ("Folgende Version gefunden: " + $dsuversion) -NoNewline -ForegroundColor Green

        If ($dsuversion -notlike "*$currentDSUversion*")
        {
            If ($vorherigerInstallationsversuch -eq "Ja")
            {
    
                # Skript beenden, falls ein vorheriger Installationsversuch fehlgeschlagen ist
                & "$pathNotificationBridge\Notify.exe" -p 3 -t "Fehler bei der Installation von DSU, Skript wird beendet."
                Write-Host "Fehler bei der Installation von DSU, Skript wird beendet." -ForegroundColor Red
                break
            }
            Else
            {
                # DSU herunterladen und installieren
                & "$pathNotificationBridge\Notify.exe" -p 0 -t "DSU nicht aktuell, beginne Aktualisierung."
                Write-Host "DSU nicht aktuell, beginne Aktualisierung."-ForegroundColor Green
                Invoke-WebRequest $downloadDSU -OutFile "$pathTempDownload\DSUSetup.exe"
                Start-Sleep -s 10
                & "$pathTempDownload\DSUSetup.exe" /s
                Start-Sleep -s 60
                $vorherigerInstallationsversuch = "Ja"
                & $checkDSU
            }
        }

    } 
    Else
    {
        If ($vorherigerInstallationsversuch -eq "Ja")
        {
            # Skript beenden, falls ein vorheriger Installationsversuch fehlgeschlagen ist
            & "$pathNotificationBridge\Notify.exe" -p 3 -t "Fehler bei der Installation von DSU, Skript wird beendet."
            Write-Host "Fehler bei der Installation von DSU, Skript wird beendet." -ForegroundColor Red
            break
        }
        Else 
        {
            # DSU herunterladen und installieren
            & "$pathNotificationBridge\Notify.exe" -p 0 -t "DSU nicht vorhanden, beginne Download."
            Write-Host "DSU nicht vorhanden, beginne Download."-ForegroundColor Green
            Invoke-WebRequest $downloadDSU -OutFile "$pathTempDownload\DSUSetup.exe"
            Start-Sleep -s 10
            & "$pathTempDownload\DSUSetup.exe" /s
            Start-Sleep -s 60
            $vorherigerInstallationsversuch = "Ja"
            & $checkDSU
        }
    }
}
& $checkDSU

# Log-Datei sichern

If (Test-Path -Path $pathDsuLog)
{
    $pathDsuLogArchiveCurrent = "$pathDsuLogArchive\Log"+(Get-Item $pathDsuLog).LastWriteTime.ToString("yyyyMMdd-HHmmss")+".txt"
    Write-Host "Log vorhanden, sichere Log." -ForegroundColor Green
    Move-Item -Path $pathDsuLog -Destination $pathDsuLogArchiveCurrent
} 
Else
{
    Write-Host "Kein Log vorhanden, fahre fort." -ForegroundColor Green
}

# Log-Dateien älter als 90 Tage bereinigen
Get-ChildItem -path $pathDsuLog -include '*.txt' | Where-Object LastWriteTime -lt (Get-Date).AddDays(-90) | Remove-Item

# DSU ausführen
& "$pathNotificationBridge\Notify.exe" -p 1 -t "Starte DELL EMC System Update"
& "$pathDsuProgram\DSU.exe" --non-interactive

# Installierte Updates zählen
$logInhalt = Get-Content $pathDsuLog
$counterInstalliert = (Select-String -InputObject $logInhalt -Pattern "Installed successfully" -AllMatches).Matches.Count
$counterNichtInstalliert = (Select-String -InputObject $logInhalt -Pattern "could not be installed" -AllMatches).Matches.Count
$textErgebnis = "Installierte Updates: "+$counterInstalliert+" Nicht installierte Updates: "+$counterNichtInstalliert

# Exit-Code auswerten
$exitCodeErfolg = $logInhalt | ForEach-Object{$_ -match "Exit Code: 0"}
$exitCodeFehler = $logInhalt | ForEach-Object{$_ -match "Exit Code: 1"}
$exitCodeUpdateFehler = $logInhalt | ForEach-Object{$_ -match "Exit Code: 24"}
$exitCodeRechtemangel = $logInhalt | ForEach-Object{$_ -match "Exit Code: 2"}
$exitCodeNeustart = $logInhalt | ForEach-Object{$_ -match "Exit Code: 8"}

If ($exitCodeErfolg -contains $true) {
    $textErfolg = "DELL EMC System Update erfolgreich abgeschlossen. "+$textErgebnis
    Write-Host $textErfolg
} 
ElseIf (($exitCodeFehler -contains $true) -or ($exitCodeUpdateFehler -contains $true)) {
    $textFehler = "DELL EMC System Update mit Fehlern beendet. "+$textErgebnis
    Write-Host $textFehler
}
ElseIf ($exitCodeRechtemangel -contains $true)
{ 
    $textRechtemangel = "DELL EMC System Update erfordert höhere Rechte!"
    Write-Host $textRechtemangel
}
ElseIf ($exitCodeNeustart -contains $true)
{
    $textRechtemangel = "DSU-Updateinstallation erfordert Neustart. "+$textErgebnis
    Write-Host $textRechtemangel
}
Else
{
    $textSonstiges = "Unbekannte Ausnahme in DELL EMC System Update. Bitte Log prüfen. "+$textErgebnis
    Write-Host $textSonstiges
}