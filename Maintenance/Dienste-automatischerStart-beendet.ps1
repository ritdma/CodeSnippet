# Dient zum Ausgeben aller gestoppten Dienste mit dem Starttyp "Automatisch"

Get-Service | Where-Object {$_.Status -eq "Stopped" -and $_.StartType -eq "Automatic"} | Select-Object -Property DisplayName | Out-GridView

Write-Host -NoNewLine "Beliebige Taste zum Beenden druecken";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");