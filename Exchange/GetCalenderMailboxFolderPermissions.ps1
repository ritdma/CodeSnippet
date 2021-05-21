$rooms=Get-Mailbox -RecipientTypeDetails "RoomMailbox"
foreach($room in $rooms) {
	$calendar=$null
	$calendar=Get-MailboxFolderPermission -Identity "$($room.userprincipalname):\Kalender" -ErrorAction SilentlyContinue
	if(!($calendar)) {
		$calendar=Get-MailboxFolderPermission -Identity "$($room.userprincipalname):\Calendar" -ErrorAction SilentlyContinue
	}
	$calendar | Select Identity,User,AccessRights
}