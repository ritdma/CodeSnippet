# R.iT GmbH | Tobias Nawrocki
# Version 1.0 | 06.02.2020

# Pfad für Ausgabe definieren und ggf erstellen
$outputPath = "C:\Protokolle\"+(Get-Date -Format yyyy-MM)
If(!(test-path $outputPath))
{
      New-Item -ItemType Directory -Force -Path $outputPath
}

# Dateinamen für Ausgabe definieren
$outputFile = $outputPath+"\Neustarts.csv"

# Neustarts abfragen
$restartList = (Get-WinEvent -FilterHashtable @{
   LogName='System'
   ID=6005
} | Select-Object TimeCreated)

$restartList | Export-Csv $outputFile -NoTypeInformation
$restartList | Out-GridView -Title "Computerneustarts (1. Alle auswählen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einfügen)"

Write-Host -NoNewLine "Beliebige Taste zum Beenden drücken";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");