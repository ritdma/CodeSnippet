# Skript zum Aktualisieren der Treiber und Firmware von Dell-Servern über DELL EMC System Update (DSU)

# Changelog #
# 26.05.2020 Tobias Nawrocki: DSU-Downloadlink von V 1.7.0 auf 1.8.0 angepasst
# 26.05.2020 Tobias Nawrocki: Anpassung rückgängig gemacht aufgrund von Pfadanpassungen in DSU

# Aktuelle Version manuell eintragen:
$downloadDSU = "https://downloads.dell.com/FOLDER05605557M/1/Systems-Management_Application_DVHNP_WN64_1.7.0_A00.EXE"

# Ordnerstruktur anlegen, falls nicht vorhanden
$logArchivPfad = "C:\Dell\DELL EMC System Update\dell_dup\Log-Archiv"
If(!(Test-Path $logArchivPfad))
{
      New-Item -ItemType Directory -Force -Path $logArchivPfad
      Write-Host "Ordner für Log-Archiv erstellt." -ForegroundColor Green
}

# Prüfen, ob DSU vorhanden ist
$vorherigerInstallationsversuch = "Nein"
$checkDSU = 
{

    If (Test-Path -Path "C:\Dell\DELL EMC System Update\DSU.exe")
    {
        
        # Aktuelle Version abfragen
        $dsuversion = & "C:\Dell\DELL EMC System Update\DSU.exe" --version | Where-Object { $_ -match '^DELL' } | Out-String
        Write-Host ("Folgende Version gefunden: " + $dsuversion) -NoNewline -ForegroundColor Green

    } 
    Else
    {
        
        If ($vorherigerInstallationsversuch -eq "Ja")
        {

            # Skript beenden, falls ein vorheriger Installationsversuch fehlgeschlagen ist
            notify -p 3 -t "Fehler bei der Installation von DSU, Skript wird beendet."
            Write-Host "Fehler bei der Installation von DSU, Skript wird beendet." -ForegroundColor Red
            break
        
        }
        Else 
        {
        
            # DSU herunterladen und installieren
            notify -p 1 -t "DSU nicht vorhanden, beginne Download."
            Write-Host "DSU nicht vorhanden, beginne Download."-ForegroundColor Green
            Invoke-WebRequest $downloadDSU -OutFile "C:\Dell\DSUSetup.exe"
            Start-Sleep -s 10
            & "C:\Dell\DSUSetup.exe" /s
            Start-Sleep -s 60
            $vorherigerInstallationsversuch = "Ja"
            & $checkDSU
        
        }

    }

}
& $checkDSU

# Log-Datei sichern
$logPfad = "C:\Dell\DELL EMC System Update\dell_dup\Log.txt"

If (Test-Path -Path $logPfad)
{
    $logZiel = "C:\Dell\DELL EMC System Update\dell_dup\Log-Archiv\Log"+(Get-Item $logPfad).LastWriteTime.ToString("yyyyMMdd-HHmmss")+".txt"
    Write-Host "Log vorhanden, sichere Log." -ForegroundColor Green
    Move-Item -Path "C:\Dell\DELL EMC System Update\dell_dup\Log.txt" -Destination $logZiel
} 
Else
{
    Write-Host "Kein Log vorhanden, fahre fort." -ForegroundColor Green
}

# Log-Dateien älter als 90 Tage bereinigen
Get-ChildItem -path $logPfad -include '*.txt' | Where-Object LastWriteTime -lt (Get-Date).AddDays(-90) | Remove-Item

# DSU ausführen
notify -p 1 -t "Starte DELL EMC System Update"
& "C:\Dell\DELL EMC System Update\DSU.exe" --non-interactive

# Installierte Updates zählen
$logInhalt = Get-Content $logPfad
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