Get-WinEvent -FilterHashtable @{
   LogName='Application'
   Level=1,2,3
} | Select-Object Id, TimeCreated, LevelDisplayName, Message | Group-Object -Property Id | Sort-Object -Property Count -Descending