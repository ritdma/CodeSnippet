# R.iT GmbH | Tobias Nawrocki
# Version 1.1

# Changelog
# Version 1.1 (14.07.2020): CSV-Export ergänzt
# Version 1.0 (31.01.2020): Erste Version

# Minimale Groesse fuer Auflistung definieren
$minFileSize = 2GB
$minDirSize = 4GB

# Nachfolgend ein Skript von "Jayowend" zum automatischen Ausfuehren als Administrator (https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell):

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }

# Hier beginnt das eigentliche Skript :)

# Pfad fuer Ausgabe definieren und ggf erstellen
$outputPath = "C:\Protokolle\"+(Get-Date -Format yyyy-MM)
If(!(test-path $outputPath))
{
      New-Item -ItemType Directory -Force -Path $outputPath
}

# Dateinamen fuer Ausgabe definieren
$outputFile = $outputPath+"\Laufwerksauswertung.txt"
$outputCsvDisks = $outputPath+"\Laufwerksauswertung_Laufwerke.csv"
$outputCsvDir = $outputPath+"\Laufwerksauswertung_Ordner.csv"
$outputCsvFiles = $outputPath+"\Laufwerksauswertung_Dateien.csv"

# Neuen Header fuer Durchfuehrung in Datei schreiben
"==== Auswertung "+(Get-Date -Format HH:mm)+" Uhr ====" | out-file $outputFile -append

# Laufwerke und Speicherplatzauslastung auflisten
$diskList = (Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '3'" |
    Select-Object @{N="Laufwerksname"; E={$_.DeviceID}},@{Name="GB gesamt";Expression={[math]::round($_.Size/1GB, 2)}},@{Name="GB frei";Expression={[math]::round($_.FreeSpace/1GB, 2)}})

$diskList | Out-File $outputFile -append
$diskList | Export-CSV $outputCsvDisks

Write-Host "Beginne mit der Analyse. Dieser Vorgang kann einige Minuten in Anspruch nehmen."

# Grosse Dateien auflisten
$path = "C:\ISOs"
$largestFiles = foreach ($disk in $diskList) {
    $path = $disk."Laufwerksname"+"\"

    Get-ChildItem -Path $path -Include *.* -Recurse -ErrorAction "SilentlyContinue" -Force -File |
    Where-Object {$_.Length -gt $minFileSize} |
    Select-Object -Property FullName, @{Name='SizeGB';Expression={[math]::round($_.Length / 1GB, 2)}}|
    Sort-Object -Property { $_.SizeGB } -Descending

}
    
$largestFiles | Out-File $outputFile -append
$largestFiles | Export-CSV $outputCsvFiles

# Grosse Ordner auflisten

# Kernfunktion "Get-DirSize" von The Scripting Guys (https://gallery.technet.microsoft.com/scriptcenter/36bf0988-867f-45be-92c0-f9b24bd766fb)

function Get-DirSize ($path){
     
    BEGIN {}

    PROCESS{ 
        $size = 0 
        $folders = @() 

        foreach ($file in (Get-ChildItem $path -Force -ErrorAction SilentlyContinue)) { 
            if ($file.PSIsContainer) { 
                $subfolders = @(Get-DirSize $file.FullName) 
                $size += $subfolders[-1].Size 
                $folders += $subfolders 
            }
            else { 
                $size += $file.Length 
            } 
        } 
   
        $object = New-Object -TypeName PSObject 
        $object | Add-Member -MemberType NoteProperty -Name Folder -Value (Get-Item $path -ErrorAction SilentlyContinue).FullName 
        $object | Add-Member -MemberType NoteProperty -Name Size -Value $size 
        $folders += $object
        Write-Output $folders
    }

    END {} 
} # end function Get-DirSize

$largeDirectories = foreach ($disk in $diskList) {
    $path = $disk."Laufwerksname"+"\"

    Get-DirSize -path $path |
    Sort-Object -Property size -Descending |
    Where-Object {$_.Folder.Length -gt 3 -and $_.Size -gt $minDirSize} |
    Select-Object -Property Folder, @{Name='SizeGB';Expression={[math]::round($_.size / 1GB, 2)}}

}

$largeDirectories | Out-File $outputFile -append
$largeDirectories | Export-CSV $outputCSVDir

$diskList | Out-GridView -Title "Laufwerke und Speicherplatz (1. Alle auswaehlen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einfuegen)"
$largestFiles | Out-GridView -Title "Groesste Dateien (1. Alle auswaehlen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einfuegen)"
$largeDirectories | Out-GridView -Title "Grosse Ordner (1. Alle auswaehlen: STRG+A | 2. Kopieren: STRG+C | 3. In Excel einfuegen)"

Write-Host -NoNewLine "Beliebige Taste zum Beenden druecken";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");