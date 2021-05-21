# R.iT GmbH | Tobias Nawrocki
# Version 1.1 | 06.02.2020

# Nachfolgend ein Skript von "Jayowend" zum automatischen Ausführen als Administrator (https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell):

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }

# Hier beginnt das eigentliche Skript :)

# Pfad für Ausgabe definieren und ggf erstellen
$outputPath = "C:\Protokolle\"+(Get-Date -Format yyyy-MM)
If(!(test-path $outputPath))
{
      New-Item -ItemType Directory -Force -Path $outputPath
}

# Dateinamen für Ausgabe definieren
$outputFile = $outputPath+"\UserMailboxSizes.csv"

# Exchange-Shell laden
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$Mailboxes = Get-Mailbox -ResultSize Unlimited | Select-Object @{Name="Benutzer";expression={$_.DisplayName}}, @{Name=“Akt. Postfachgröße (in MB)“;expression={(Get-MailboxStatistics $_).TotalItemSize.Value.ToMB()}}, @{Name="Laufwerksname";expression={$_.ProhibitSendQuota}}

$Mailboxes | Export-Csv $outputFile -NoTypeInformation
$Mailboxes | Out-GridView -Title "Postfächer (1. Alle auswählen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einfügen)"

Write-Host -NoNewLine "Beliebige Taste zum Beenden drücken";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");