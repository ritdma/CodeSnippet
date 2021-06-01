## Das Script muss als Administrator gestartet werden

##Richtigen UPN hier ersetzen
$userpriname = "username@tenant.onmicrosoft.com"
Install-Module exchangeonlinemanagement
Connect-ExchangeOnline -userprincipalname $userpriname