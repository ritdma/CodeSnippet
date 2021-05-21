### Script for controlling the amount of FullBackups on every external HDD
### Version 1.0 R.iT GmbH 11.03.2020, Last Change Niklas Zistler 11.03.2020

#Varivable
$backupPath =    ## Example: 'E:\Backups\Offsite\'
$copyJob = Get-VBRJob -Name ""
$olerThan =      ## Example: -15

### Execute Single Backup to external HDD and remove FullBackups older than $olderThan.
    Get-ChildItem -path $backupPath -Include '*.vbk' ,'*.vib', '*.vbm' -Recurse | Where-Object LastWriteTime -lt (Get-Date).AddDays($olerThan) | Remove-Item
    Add-PSSnapin VeeamPSSnapin
    Try {
        Enable-VBRJob -Job $CopyJob
        Sync-VBRBackupCopyJob -Job $CopyJob -FullBackup #-ErrorAction Stop
    }
    
   ### Option for sending Mail, if the script ends with an error
   Catch {
    #    Send-MailMessage -From -to -Cc -bcc -Subject "Script Offsite-HDD fehlgeschlagen!" -SmtpServer -Body "Bei der Aktivierung oder der aktiven Vollsynchronisation des Jobs $CopyJob ist etwas schief gegangen! Bitte manuell analysieren."
    #    Break
   }