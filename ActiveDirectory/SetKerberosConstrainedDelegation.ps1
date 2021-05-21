#Import Active Directory PowerShell CMDlets
Import-Module ActiveDirectory

#Set Hostname of Windows Admin Server
$wac = "wac01"

# Server and Cluster which should be mananged with Windows Admin Center
$servers = "HV1", "HV2", "HV3", "HV4", "APP01", "mailarchiv1", "DEV-CRM4", "NoSpamProxy", "VPN01", "colab3", "db02n2", "file1", "RDS16-1", "dev-dc1", "dev-sql1", "dev-crm1", "dev-crm3", "NPS01", "DEV-SQL2", "colab4", "scvmm1", "tfs15", "DEV-DC2", "ELOSRV1", "ds9", "ADFS01", "ca01", "SDN01", "DEV-CRM6", "ELOSRV2", "DB02N1", "CORE2", "dynamics01", "core1", "DC01", "RDS03", "DEV-CRM5", "directaccess1", "VDIGATE"

$wacobject = Get-ADComputer -Identity $wac

# Set Kerberos Constraited delegation for each server in the list above
foreach ($server in $servers){
    $serverObject = Get-ADComputer -Identity $server
    Set-ADComputer -Identity $serverObject -PrincipalsAllowedToDelegateToAccount $wacobject
}