﻿# Grab credentials to connect to remote hosts with
$creds = Get-Credential

# Initialise target IPs
$target_ips = @(
    "172.16.12.7",
    "172.16.12.8",
    "172.16.12.9",
    "172.16.12.10",
    "172.16.12.11",
    "172.16.12.12",
    "172.16.12.13"
)
# Prepare for remote connection
$trusted_hosts = $target_ips -join ","
Set-Item wsman:\localhost\client\trustedhosts -Value $trusted_hosts -Force

# Check each of the target machines
ForEach ($target_ip in $target_ips) {
    Write-Host -ForegroundColor Yellow "[?] Conducting interrogation of host $($target_ip)"
    Invoke-Command -ComputerName $target_ip -Credential $creds -ScriptBlock {
        Get-LocalUser | Select-Object -Property Name, Enabled, SID | Format-Table -AutoSize
    
        Get-LocalGroupMember -Group "Administrators" | Format-Table -AutoSize

        # Look for events with ID 4732 - "A member was added to a security-enabled local group
        Get-EventLog -LogName Security -InstanceId 4732 -ErrorAction SilentlyContinue | Format-List

        Start-Sleep -Seconds 1
    }
}
