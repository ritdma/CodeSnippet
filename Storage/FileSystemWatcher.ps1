#By BigTeddy 05 September 2011
#Anpassungen Niklas Zistler 8.11.2019
#This script uses the .NET FileSystemWatcher class to monitor file events in folder(s).
#The advantage of this method over using WMI eventing is that this can monitor sub-folders.
#The -Action parameter can contain any valid Powershell commands.  I have just included two for example.
#The script can be set to a wildcard filter, and IncludeSubdirectories can be changed to $true.
#You need not subscribe to all three types of event.  All three are shown for example.


$rootSourceFolder = 's:\' # Zu überwachendes Verzeichnis.
$rootDestinationFolder ='t:\' #Stammpfad für das Ziel
$filter = '*.*'  # Filtermöglichkeiten für Dateien.
$logPath = 'C:\Skripte\' # Pfad für die Logdatei

# In the following line, you can change 'IncludeSubdirectories to $true if required.                          
$fsw = New-Object IO.FileSystemWatcher $rootSourceFolder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}

# Aktion beim eintreten des Events "eine neue Datei ist erstellt worden":

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
$newFile = $Event.SourceEventArgs.Name
$changeType = $Event.SourceEventArgs.ChangeType
$timeStamp = $Event.TimeGenerated
$currentYear = (Get-Item $newFile).LastWriteTime.ToString("yyyy")
$sourceFolder = $rootSourceFolder+$newFile
$destinationFolder = $rootDestinationFolder+$currentYear+'\'
if ((Get-ChildItem -Path $rootDestinationFolder -Name "$currentYear") -eq $currentYear){
    Copy-Item -Path $sourceFolder -Destination $destinationFolder -Recurse -Force
    }
    else{
    New-Item -path "$destinationFolder" -ItemType Directory
    Copy-Item -Path $sourceFolder -Destination $destinationFolder -Recurse -Force
    }
Out-File -FilePath $logPath'MoinitorFolderLog.txt' -Append -InputObject "The file '$destinationFolder$newFile' was $changeType at $timeStamp"}



# To stop the monitoring, run the following commands:
# Unregister-Event FileDeleted
# Unregister-Event FileCreated
# Remove-Event FileCreated
# Unregister-Event FileChanged