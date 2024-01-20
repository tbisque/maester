<#
 .Synopsis
  Checks if the tenant has at least one conditional access policy requiring multifactor authentication to access Azure management.

 .Description
    MFA for Azure management is a critical security control. This function checks if the tenant has at least one
    conditional access policy requiring multifactor authentication to access Azure management.

  Learn more:
  https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-policy-azure-management

 .Example
  Test-MtCaMfaForAdminManagement
#>

Function Test-MtCaMfaForAdminManagement {
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    Set-StrictMode -Off
    $policies = Get-MtConditionalAccessPolicies | Where-Object { $_.state -eq "enabled" }

    $result = $false
    foreach ($policy in $policies) {
        if ( ( $policy.grantcontrols.builtincontrols -contains 'mfa' -or $policy.grantcontrols.authenticationStrength.requirementsSatisfied -contains 'mfa' ) -and $policy.conditions.users.includeUsers -eq "All" -and "797f4846-ba00-4fd7-ba43-dac1f8f63013" -in $policy.conditions.applications.includeApplications ) {
            $result = $true
            $currentresult = $true
        } else {
            $currentresult = $false
        }
        Write-Verbose "$($policy.displayName) - $currentresult"
    }
    Set-StrictMode -Version Latest

    return $result
}