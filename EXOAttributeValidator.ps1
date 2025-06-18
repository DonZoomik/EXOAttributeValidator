#RecipientType
$msExchRecipientDisplayType = @{
"MailboxUser" = 0;
"DistributionGroup" = 1;
"PublicFolder"= 2 ;
"DynamicDistributionGroup" = 3;
"RemoteMailUser" = 6;
"ConferenceRoomMailbox" = 7;
"EquipmentMailbox" = 8;
"SecurityDistributionGroup" = 1073741833;
"ACLableMailboxUser" = 1073741824;
"ACLableRemoteMailUser" = 1073741830;
"Organization" = 4;
"PrivateDistributionList" = 5;
"ArbitrationMailbox" = 10;
"MailboxPlan" = 11;
"LinkedUser" = 12;
"RoomList" = 15;
"SyncedUDGasContact" = -2147483386;
"SyncedUDGasUDG" = -2147483391;
"SyncedUSGasUDG" = -2147481343;
"SyncedUSGasUSG" = -1073739511;
"SyncedUSGasContact" = -2147481338;
"ACLableSyncedUSGasContact" = -1073739514;
"SyncedDynamicDistributionGroup" = -2147482874;
"ACLableSyncedMailboxUser" = -1073741818;
"SyncedMailboxUser" = -2147483642;
"SyncedConferenceRoomMailbox" = -2147481850;
"SyncedEquipmentMailbox" = -2147481594;
"SyncedRemoteMailUser" = -2147482106;
"ACLableSyncedRemoteMailUser" = -1073740282;
"SyncedPublicFolder" = -2147483130




}
$msExchRecipientTypeDetails = @{
"None" = 0;
"UserMailbox" = 1;
"LinkedMailbox" = 2;
"SharedMailbox" = 4;
"LegacyMailbox" = 8;
"RoomMailbox" = 16;
"EquipmentMailbox" = 32;
"MailContact" = 64;
"MailUser" = 128;
"MailUniversalDistributionGroup" = 256;
"MailNonUniversalGroup" = 512;
"MailUniversalSecurityGroup" = 1024;
"DynamicDistributionGroup" = 2048;
"PublicFolder" = 4096;
"SystemAttendantMailbox" = 8192;
"SystemMailbox" = 16384;
"MailForestContact" = 32768;
"User" = 65536;
"Contact" = 131072;
"UniversalDistributionGroup" = 262144;
"UniversalSecurityGroup" = 524288;
"NonUniversalGroup" = 1048576;
"DisabledUser" = 2097152;
"MicrosoftExchange" = 4194304;
"ArbitrationMailbox" = 8388608;
"MailboxPlan" = 16777216;
"LinkedUser" = 33554432;
"RoomList" = 268435456;
"DiscoveryMailbox" = 536870912;
"RoleGroup" = 1073741824;
"RemoteUserMailbox" = 2147483648;
"Computer" = 4294967296;
"RemoteRoomMailbox" = 8589934592;
"RemoteEquipmentMailbox" = 17179869184;
"RemoteSharedMailbox" = 34359738368;
"PublicFolderMailbox" = 68719476736;
"TeamMailbox" = 137438953472;
"RemoteTeamMailbox" = 274877906944;
"MonitoringMailbox" = 549755813888;
"GroupMailbox" = 1099511627776;
"LinkedRoomMailbox" = 2199023255552;
"AuditLogMailbox" = 4398046511104;
"RemoteGroupMailbox" = 8796093022208;
"SchedulingMailbox" = 17592186044416;
"GuestMailUser" = 35184372088832;
"AuxAuditLogMailbox" = 70368744177664;
"SupervisoryReviewPolicyMailbox" = 140737488355328
}
$msExchRemoteRecipientType = @{
"None" = 0;
"ProvisionMailbox" = 1;
"ProvisionArchive" = 2;
"ProvisionMailbox, ProvisionArchive " = 3;
"Migrated" = 4;
"ProvisionArchive, Migrated" = 6
"DeprovisionMailbox" = 8;
"ProvisionArchive, DeprovisionMailbox" = 10;
"DeprovisionArchive" = 16;
"ProvisionMailbox, DeprovisionArchive" = 17;
"DeprovisionArchive, Migrated" = 20;
"Migrated, DeprovisionArchive" = 20; #can be both ways according to doc
"DeprovisionMailbox, DeprovisionArchive" = 24;
"RoomMailbox" = 32;
"ProvisionMailbox, RoomMailbox" = 33
"ProvisionMailbox, ProvisionArchive, RoomMailbox" = 35
"Migrated, RoomMailbox" = 36
"ProvisionArchive, Migrated, RoomMailbox" = 38;
"ProvisionMailbox, DeprovisionArchive, RoomMailbox" = 49;
"Migrated, DeprovisionArchive, RoomMailbox" = 52;
"EquipmentMailbox" = 64
"ProvisionMailbox, EquipmentMailbox" = 65;
"ProvisionMailbox, ProvisionArchive, EquipmentMailbox" = 67
"Migrated, EquipmentMailbox" = 68
"ProvisionArchive, Migrated, EquipmentMailbox" = 70
"ProvisionMailbox, DeprovisionArchive, EquipmentMailbox" = 81
"Migrated, DeprovisionArchive, EquipmentMailbox" = 84
"SharedMailbox" = 96
"Migrated, SharedMailbox" = 100
"ProvisionArchive, Migrated, SharedMailbox" = 102
"Migrated, DeprovisionArchive, SharedMailbox" = 116
}

$o365validstates = Import-Csv C:\Dev\O365ValidStates.csv -Delimiter ';' -Encoding Default

$EXOMbxs=get-mailbox

$invalidmbxs = @()
ForEach ($EXOMbx in $EXOMbxs) {
    $UserPrincipalName = $EXOMbx.UserPrincipalName
    $ADUser = Get-ADUser -filter "UserPrincipalName -eq `"$UserPrincipalName`"" -Properties userprincipalname,msExchRecipientDisplayType,msExchRecipientTypeDetails,msExchRemoteRecipientType,objectClass,msExchResourceMetaData -ea SilentlyContinue
    If (!($ADUser)) {
        Write-Host ("Missing user for " + $EXOMbx.alias) -ForegroundColor Yellow
    } Else {
        $ValidState = $o365validstates|Where-Object -FilterScript {
            $EXOMbx.RemoteRecipientType -eq $_.'EXO-RemoteRecipientType' -and `
            $EXOMbx.RecipientType -eq $_.'EXO-RecipientType' -and `
            $EXOMbx.RecipientTypeDetails -eq $_.'EXO-RecipientTypeDetails'
        }
        If ($validstate) {
            If (
                $ADUser.msExchRecipientDisplayType -eq $validstate.'AD-msExchRecipientDisplayType' -and `
                $ADUser.msExchRecipientTypeDetails -eq $validstate.'AD-msExchRecipientTypeDetails' -and `
                $ADUser.msExchRemoteRecipientType -eq $validstate.'AD-msExchRemoteRecipientType' <#-and `
                $ADUser.msExchResourceMetaData -eq $validstate.'AD-msExchResourceMetaData' -and `
                $ADUser.objectClass -eq $validstate.'AD-objectClass'#>
            ) {
                #write-host ($UserPrincipalName + " is in valid state") -ForegroundColor Green
            } Else {
                #write-host ($UserPrincipalName + " AD attribute mismatch") -ForegroundColor DarkYellow
            }
        } else {
            $invalidmbxs += $EXOMbx
        }
    }
}
#sort by type
$invalidmbxs |select RemoteRecipientType,RecipientType,RecipientTypeDetails,ResourceType -Unique
$invalidmbxs |group RemoteRecipientType,RecipientType,RecipientTypeDetails,ResourceType|ft -AutoSize

$invalidmbxs|?{$_.RecipientTypeDetails -eq 'SharedMailbox'}|select alias,RemoteRecipientType,RecipientType,RecipientTypeDetails,ResourceType


#provisioned shared to remoteshared, migrated
$invalidmbxs|?{ $_.RemoteRecipientType -eq 'ProvisionMailbox' -and $_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'SharedMailbox'}|%{$_.primarysmtpaddress}
$invalidmbxs|?{ $_.RemoteRecipientType -eq 'ProvisionMailbox' -and $_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'SharedMailbox'}|%{get-aduser $_.alias -Properties msExchRecipientDisplayType,msExchRecipientTypeDetails,msExchRemoteRecipientType}|ft

$invalidmbxs|?{ $_.RemoteRecipientType -eq 'ProvisionMailbox' -and $_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'SharedMailbox'}|%{set-aduser $_.alias -Replace @{msExchRecipientDisplayType='-2147483642';msExchRecipientTypeDetails='34359738368';msExchRemoteRecipientType='100'} -enabled $false -WhatIf}

#migrated shared to remoteshared, migrated
$invalidmbxs|?{ $_.RemoteRecipientType -eq 'Migrated' -and $_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'SharedMailbox'}|%{$u=$_.userprincipalname;get-aduser -filter "userprincipalname -eq `"$u`"" -Properties msExchRecipientDisplayType,msExchRecipientTypeDetails,msExchRemoteRecipientType}|ft

#none to remote
$invalidmbxs|?{ $_.RemoteRecipientType -eq 'None' -and $_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'UserMailbox'}|%{$u=$_.userprincipalname;get-aduser -filter "userprincipalname -eq `"$u`"" -Properties userprincipalname,msExchRecipientDisplayType,msExchRecipientTypeDetails,msExchRemoteRecipientType,mailnickname,msExchPoliciesExcluded,proxyaddresses}|ft userprincipalname,enabled,msExchRecipientDisplayType,msExchRecipientTypeDetails,msExchRemoteRecipientType,mailnickname,msExchPoliciesExcluded,@{l='proxy';e={$_.proxyaddresses|?{$_ -match 'smtp:'}}} -auto

#fixup rooms
$invalidmbxs|?{$_.RemoteRecipientType -eq



%{set-aduser $_.alias -Replace @{msExchRecipientDisplayType='-2147483642';msExchRecipientTypeDetails='34359738368';msExchRemoteRecipientType='100'} -enabled $false -WhatIf}

$EXOMbxs|?{$_.RemoteRecipientType -eq 'ProvisionMailbox' -and $_.RecipientType -eq 'UserMailbox' -and $_.RecipientTypeDetails -eq 'SharedMailbox'}|%{ Get-ADUser -filter "UserPrincipalName -eq `"$($_.UserPrincipalName)`"" -Properties userprincipalname,msExchRecipientDisplayType,msExchRecipientTypeDetails,msExchRemoteRecipientType,objectClass,msExchResourceMetaData}|%{set-aduser $_.alias -Replace @{msExchRecipientDisplayType='-2147483642';msExchRecipientTypeDetails='34359738368';msExchRemoteRecipientType='100'} -enabled $false -WhatIf}