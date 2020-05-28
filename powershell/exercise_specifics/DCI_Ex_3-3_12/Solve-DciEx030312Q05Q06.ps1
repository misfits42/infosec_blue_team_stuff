# Read in the baseline file and make the dict
$baseline_sha256 = @{}
$last_hash = ""
$last_path = ""
Write-Output "##################################################"
Write-Output "[*] Building the baseline dictionary..."
Get-Content "System32baseline.txt" | ForEach-Object {
    if ($_ -match "C:") { # Got a filepath line - now we have a baseline entry pair
        $last_path = $_
        $baseline_sha256.Add($last_path, $last_hash)
    } else { # File hash line - still need the filepath on next line
        $last_hash = $_
    }
}
# Ex 3.3-12 Q6 --- check for files in baseline
$checks = (
    "recover.exe",
    "recdisc.exe",
    "recover.dat",
    "drivers.inf",
    "systemrestore.exe"
)
ForEach ($check in $checks) {
    # Generate filepath for file in System32 dir
    $filepath = [string]::Format("C:\Windows\System32\{0}", $check)
    if ($baseline_sha256.Contains($filepath)) { # First check if in baseline
        if ((Test-Path -Path $filepath) -eq $true) { # Check if file is on live system
            Write-Output "[+] (Q6) File in baseline and System32 dir of live system: $filepath"
        }
    }
}
Write-Output "##################################################"
# Process each file on live system, check if in baseline, calculate hash and compare
Get-ChildItem -Path "C:\" -Recurse | ForEach-Object {
    # Check if file is in the baseline - ignore files not in baseline
    if ($baseline_sha256.Contains($_.FullName)) {
        $live_hash = (Get-FileHash -Algorithm SHA256 $_.FullName).Hash
        if ($live_hash -ne $baseline_sha256[$_.FullName]) {
            Write-Output "[+] (Q5) Mismatched SHA256 hash: $($_.FullName)"
        }
    }
}