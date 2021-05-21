# Prüfung, ob ein Übergebner Thumbprint und damit ein Zertifikat auf dem System existiert.
# Niklas Zistler 14.12.2020
# Version: 1.1
# Letzte Änderung durch: Tobias Nawrocki

# ChangeLog
# Version 1.1: Entfernen möglicher Leerzeichen ergänzt 16.03.2021
# Version 1.0: Erste Version 14.12.2020

#Variablen Definition
$thumbprint

#Anwender auffordern den gewünschten Thumbprint einzugeben.
$thumbprint = Read-Host -Prompt "Thumbprint eingeben" 

#Eventuell vorhandene Leerzeichen entfernen:
$thumbprint = $thumbprint -replace '\s',''

#In den Zertifikatsspeicher wecheseln
Set-Location -Path "cert:\"

#Zertifikate mit dem übergebenen Thumbprint vergleichen
Get-ChildItem .\\LocalMachine\ -Recurse | Where-Object Thumbprint -eq $thumbprint | Format-List

#Ende des Skripts
Write-Host -NoNewLine "Beliebige Taste zum Beenden druecken";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");