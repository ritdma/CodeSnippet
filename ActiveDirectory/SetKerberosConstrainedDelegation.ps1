#Import Active Directory PowerShell CMDlets
Import-Module ActiveDirectory

#Set Hostname of Windows Admin Server
$wac = ""

# Server and Cluster which should be mananged with Windows Admin Center
$servers = ""

$wacobject = Get-ADComputer -Identity $wac

# Set Kerberos Constraited delegation for each server in the list above
foreach ($server in $servers){
    $serverObject = Get-ADComputer -Identity $server
    Set-ADComputer -Identity $serverObject -PrincipalsAllowedToDelegateToAccount $wacobject
}