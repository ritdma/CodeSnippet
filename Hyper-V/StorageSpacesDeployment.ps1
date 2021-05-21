$s = Get-StorageSubSystem
$spName = ""
$vdName = ""
$cols_ssdTier = 2    # how to incorporate those value?
$cols_hddTier = 4    # how to incorporate those value?
$s_CacheSize = 20       # maximum possible size according to above sizes
$s_WBC = $s_CacheSize*1073741824
$SSD_TierName = "SSD_Tier"
$HDD_TierName = "HDD_Tier"

# create storage pool

New-StoragePool -StorageSubSystemUniqueId $s.UniqueId -FriendlyName $spName -PhysicalDisks (Get-PhysicalDisk -CanPool $true)

 

# create storage tiers

$ssdTier = New-StorageTier -StoragePoolFriendlyName $spName -FriendlyName $SSD_TierName -MediaType SSD -NumberOfColumns $cols_ssdTier
$hddTier = New-StorageTier -StoragePoolFriendlyName $spName -FriendlyName $HDD_TierName -MediaType HDD -NumberOfColumns $cols_hddTier
$s_ssdTier = (Get-StorageTierSupportedSize -FriendlyName $SSD_TierName -ResiliencySettingName Mirror).TierSizeMax - $s_WBC
$s_hddTier = (Get-StorageTierSupportedSize -FriendlyName $HDD_TierName -ResiliencySettingName Mirror).TierSizeMax - 2*1073741824 


# create and initialize the virtual disk

Get-StoragePool $spName | New-VirtualDisk -FriendlyName $vdName -StorageTiers $ssdTier, $hddTier -StorageTierSizes $s_ssdTier, $s_hddTier -ResiliencySettingName "Mirror" -NumberOfDataCopies 2 -WriteCacheSize $s_WBC

Initialize-Disk -VirtualDisk (Get-VirtualDisk -FriendlyName $vdName)