# Get all disabled users in the domain
$disabledUsers = Get-ADUser -Filter 'Enabled -eq $false' -Properties MemberOf, DistinguishedName

foreach ($user in $disabledUsers) {
    $groups = Get-ADUser $user.DistinguishedName -Properties MemberOf | Select-Object -ExpandProperty MemberOf

    foreach ($groupDN in $groups) {
        try {
            $groupName = (Get-ADGroup $groupDN).Name

            # Optional: Skip certain groups if needed
            if ($groupName -ne "Domain Users") {
                Write-Host "Removing $($user.SamAccountName) from $groupName"
                Remove-ADGroupMember -Identity $groupDN -Members $user -Confirm:$false
            }
        }
        catch {
            Write-Warning "Failed to remove $($user.SamAccountName) from $groupDN - $_"
        }
    }
}
