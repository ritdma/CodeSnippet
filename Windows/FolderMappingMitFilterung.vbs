On Error Resume Next

Set objNetwork = CreateObject("WScript.Network")
Set objShell = WScript.CreateObject("WScript.Shell")
Set objSysInfo = CreateObject("ADSystemInfo")

' Anmeldeinformationen speichern
strDriveUser = "benutzer"
strDrivePass = "kennwort"

' Laufwerksdetails angeben
strDriveName = "Z:"
strDrivePersistence = "True"

' DN ermitteln
strUserDN = objSysInfo.UserName

' Benutzerobjekt verknuepfen
Set objUser = GetObject("LDAP://" & strUserDN)

' Vornamen ermitteln
strFirstName = objUser.givenName

' Nachnamen ermitteln
strLastName = objUser.sn

' Laufwerkspfad a zusammenfuegen
If IsMember("gruppe_a") <> 0 Then
strDrivePathComplete = "\\192.168.0.13\" & strFirstName & "." & strLastName
End If

' Laufwerkspfad b zusammenfuegen
If IsMember("gruppe_b") <> 0 Then
strDrivePathComplete = "\\192.168.50.13\" & strFirstName & "." & strLastName
End If

' Laufwerk verbinden
objNetwork.RemoveNetworkDrive "Z:", True
objNetwork.MapNetworkDrive strDriveName, strDrivePathComplete, strDrivePersistence, strDriveUser, strDrivePass

' Funktion zum Pruefen der Gruppenmitgliedschaft
' Quelle: https://www.experts-exchange.com/questions/22753448/Need-a-VBscript-that-maps-network-drives-depending-on-user-OU-memership.html

Private Function IsMember(groupName)

  Set netObj = CreateObject("WScript.Network")
  domain = netObj.UserDomain
  user = netObj.UserName
  flgIsMember = false
  Set userObj = GetObject("WinNT://" & domain & "/" & user & ",user")
  For Each grp In userObj.Groups
    If grp.Name = groupName Then
      flgIsMember = true
      Exit For
    End If
  Next
  IsMember = flgIsMember
  Set userObj = Nothing

End Function

' Syntax:
' objNetwork.RemoveNetworkDrive(strName, [bForce], [bUpdateProfile])
' objNetwork.MapNetworkDrive(strLocalDrive, strRemoteShare, [persistent], [strUser], [strPassword])