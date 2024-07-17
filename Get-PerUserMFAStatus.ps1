$users = Get-MsolUser -All | Where-Object { $_.UserPrincipalName -notlike "*svc*" }
$results = @()

foreach ($user in $users) {
    $authMethods = $user.StrongAuthenticationMethods
    $mfaStatus = ""

if ($user.StrongAuthenticationRequirements -eq $null -or $user.StrongAuthenticationRequirements[0].State -eq "Disabled") {
    $mfaStatus = "Disabled"
} elseif ($user.StrongAuthenticationRequirements[0].State -eq "Enforced" -and $authMethods.Count -eq 0) {
    $mfaStatus = "Enabled"
} elseif ($user.StrongAuthenticationRequirements[0].State -eq "Enabled" -and $authMethods.Count -eq 0) {
    $mfaStatus = "Enabled"
} elseif ($authMethods.Count -gt 0) {
    $mfaStatus = "Enforced"
} else {
    $mfaStatus = "Disabled"
}

    $results += [pscustomobject]@{
        DisplayName = $user.DisplayName
        MFAStatus = $mfaStatus
        Email = $user.UserPrincipalName
    }
}

$results | Export-Csv -Path "UsersMFAstatus.csv" -NoTypeInformation
