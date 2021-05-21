##List of users. Example: "user1@example.com", "user2@example.com"
$Users = "" 
$RoomIdentity = ""
foreach($User in $Users){
	Add-MailboxFolderPermission -Identity $RoomIdentity -User $User -AccessRights Owner
}