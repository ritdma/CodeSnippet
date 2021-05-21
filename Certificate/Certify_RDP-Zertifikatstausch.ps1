# Austauschen der Zertifikate für das RD-Gateway und die RD-Bereitstellung

param($result)

Import-Module RemoteDesktopServices
Import-Module RemoteDesktop

# Einrichten im Gateway (Auskommentieren bei Nichtvorhandensein)

Set-Item -Path RDS:\GatewayServer\SSLCertificate\Thumbprint -Value  $result.ManagedItem.CertificateThumbprintHash -ErrorAction Stop

# Neustarten des RD-Gateways

Restart-Service TSGateway -Force -ErrorAction Stop

# Aufrufen der 64-Bit-PowerShell (Certify startet in 32-Bit)

set-alias ps64 "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
ps64 -args $result -command {
   $result = $args[0]
   Import-Module RemoteDesktop
   Set-RDCertificate -Role RDGateway -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force
   Set-RDCertificate -Role RDWebAccess -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force
   Set-RDCertificate -Role RDPublishing -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force
   Set-RDCertificate -Role RDRedirector -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force
}

Set-RDCertificate -Role RDGateway -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force
Set-RDCertificate -Role RDWebAccess -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force
Set-RDCertificate -Role RDPublishing -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force
Set-RDCertificate -Role RDRedirector -Thumbprint $result.ManagedItem.CertificateThumbprintHash -Force