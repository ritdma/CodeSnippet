New-VMSwitch -Name VMNET -NetAdapterName Team01 -AllowManagementOS $False -MinimumBandwidthMode Weight
Set-VMSwitch "VMNET" -DefaultFlowMinimumBandwidthWeight 3
Add-VMNetworkAdapter -ManagementOS -Name "Management" -SwitchName "VMNET"
Add-VMNetworkAdapter -ManagementOS -Name "LiveMigration" -SwitchName "VMNET"
Add-VMNetworkAdapter -ManagementOS -Name "CSV" -SwitchName "VMNET" 
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Management" -Access -VlanId 185
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "CSV" -Access -VlanId 195
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "LiveMigration" -Access -VlanId 196
Set-VMNetworkAdapter -ManagementOS -Name "LiveMigration" -MinimumBandwidthWeight 40
Set-VMNetworkAdapter -ManagementOS -Name "CSV" -MinimumBandwidthWeight 10
Set-VMNetworkAdapter -ManagementOS -Name "Management" -MinimumBandwidthWeight 10