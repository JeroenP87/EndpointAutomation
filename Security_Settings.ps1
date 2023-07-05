#Security Settings for Endpoints used in Intune Proactive Remediation
#2023.07.05 potsolutions.nl

$osInfo = Get-WmiObject -Class Win32_OperatingSystem
if ($osInfo.ProductType -ne 1) { 
    #Script not intended for non-workstation devices.
    exit
}

$regkeys = @(
    [pscustomobject]@{Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';Name='RunAsPPL';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';Name='DisableDomainCreds';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown';Name='bDisableJavaScript';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown';Name='bEnableFlash';Value='0';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer';Name='AlwaysInstallElevated';Value='0';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\policies\Microsoft\Windows NT\DNSClient';Name='EnableMulticast';Value='0';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp';Name='DisableWpad';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown';Name='bEnhancedSecurityStandalone';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown';Name='bEnhancedSecurityInBrowser';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown';Name='bProtectedMode';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown';Name='iProtectedView';Value='2';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown';Name='bEnableProtectedModeAppContainer';Value='1';PropertyType='DWORD'}
    [pscustomobject]@{Path='HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy';Name='VerifiedAndReputablePolicyState';Value='1';PropertyType='DWORD'}
)
$remediated = 0

#disable netbios
set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces\tcpip* -Name NetbiosOptions -Value 2

#disable ipv6
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6

foreach ($regkey in $regkeys) {
    foreach ($value in (Get-ItemProperty -Path "HKLM:\SOFTWARE\MSP\Settings\" -Name $regkey.Name -ErrorAction SilentlyContinue)) {
        $regkey.Value = $value.$($regkey.Name)
    }

    If (-NOT (Test-Path $regkey.Path)) {
        New-Item -Path $regkey.Path -Force | Out-Null
    }  
    $cregkey = (Get-ItemProperty -Path $regkey.Path -Name $regkey.Name -ErrorAction SilentlyContinue).$($regkey.Name)

    $cregkeytype = ((Get-ItemProperty $regkey.Path -Name $regkey.Name -ErrorAction SilentlyContinue | Get-Member | Where-Object{$_.Name -eq $regkey.Name}).Definition -split " ")[0]
    if ($cregkeytype -eq "int") { $cregkeytype = "DWORD" }

    if ($regkey.Value -ne $cregkey -or $regkey.PropertyType -ne $cregkeytype) {
        $remediated = 1
        New-ItemProperty -Path $regkey.Path -Name $regkey.Name -Value $regkey.Value -PropertyType $regkey.PropertyType -Force
    }
}

exit $remediated
