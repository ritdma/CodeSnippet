$servername = ""
$internalhostname = "" 
$externalhostname = "" 
$autodiscoverhostname = "" 
$owainturl = "https://" + "$internalhostname" + "/owa"
$owaexturl = "https://" + "$externalhostname" + "/owa"
$ecpinturl = "https://" + "$internalhostname" + "/ecp" 
$ecpexturl = "https://" + "$externalhostname" + "/ecp" 
$ewsinturl = "https://" + "$internalhostname" + "/EWS/Exchange.asmx" 
$ewsexturl = "https://" + "$externalhostname" + "/EWS/Exchange.asmx" 
$easinturl = "https://" + "$internalhostname" + "/Microsoft-Server-ActiveSync" 
$easexturl = "https://" + "$externalhostname" + "/Microsoft-Server-ActiveSync" 
$oabinturl = "https://" + "$internalhostname" + "/OAB" 
$oabexturl = "https://" + "$externalhostname" + "/OAB" 
$mapiinturl = "https://" + "$internalhostname" + "/mapi" 
$mapiexturl = "https://" + "$externalhostname" + "/mapi" 
$aduri = "https://" + "$autodiscoverhostname" + "/Autodiscover/Autodiscover.xml" 
Get-OwaVirtualDirectory -Server $servername | Set-OwaVirtualDirectory -internalurl $owainturl -externalurl $owaexturl
Get-EcpVirtualDirectory -server $servername | Set-EcpVirtualDirectory -internalurl $ecpinturl -externalurl $ecpexturl
Get-WebServicesVirtualDirectory -server $servername | Set-WebServicesVirtualDirectory -internalurl $ewsinturl -externalurl $ewsexturl
Get-ActiveSyncVirtualDirectory -Server $servername | Set-ActiveSyncVirtualDirectory -internalurl $easinturl -externalurl $easexturl
Get-OabVirtualDirectory -Server $servername | Set-OabVirtualDirectory -internalurl $oabinturl -externalurl $oabexturl
Get-MapiVirtualDirectory -Server $servername | Set-MapiVirtualDirectory -externalurl $mapiexturl -internalurl $mapiinturl
Get-OutlookAnywhere -Server $servername | Set-OutlookAnywhere -externalhostname $externalhostname -internalhostname $internalhostname -ExternalClientsRequireSsl:$true -InternalClientsRequireSsl:$true -ExternalClientAuthenticationMethod 'Negotiate'
Get-ClientAccessService $servername | Set-ClientAccessService -AutoDiscoverServiceInternalUri $aduri