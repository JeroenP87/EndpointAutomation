#Chocolatey Manage Local Files
#2023.07.04 potsolutions.nl

$osInfo = Get-WmiObject -Class Win32_OperatingSystem
if ($osInfo.ProductType -ne 1) { 
    #Script not intended for non-workstation devices.
    exit
}

$updaterefs = @(
    [pscustomobject]@{Name='foxitreader';Path='C:\Program Files\Foxit Software\Foxit Reader\FoxitReader.exe';checksum=''}
    [pscustomobject]@{Name='foxitreader';Path='C:\Program Files (x86)\Foxit Software\Foxit Reader\FoxitReader.exe';checksum=''}
    [pscustomobject]@{Name='winrar';Path='C:\Program Files\WinRAR\WinRAR.exe';checksum=''}
    [pscustomobject]@{Name='winrar';Path='C:\Program Files (x86)\WinRAR\WinRAR.exe';checksum=''}
    [pscustomobject]@{Name='googlechrome';Path='C:\Program Files\Google\Chrome\Application\chrome.exe';checksum=''}
    [pscustomobject]@{Name='googlechrome';Path='C:\Program Files (x86)\Google\Chrome\Application\chrome.exe';checksum=''}
    [pscustomobject]@{Name='fireFox';Path='C:\Program Files\Mozilla Firefox\firefox.exe';checksum=''}
    [pscustomobject]@{Name='fireFox';Path='C:\Program Files (x86)\Mozilla Firefox\firefox.exe';checksum=''}
    [pscustomobject]@{Name='jre8';Path='C:\Program Files\Java\jre1.8*';checksum=''}
    [pscustomobject]@{Name='foxitreader';Path='C:\Program Files (x86)\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe';checksum='--ignore-checksums'}
    [pscustomobject]@{Name='foxitreader';Path='C:\Program Files\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe';checksum='--ignore-checksums'}
    [pscustomobject]@{Name='adobereader';Path='C:\Program Files\Adobe\Acrobat Reader DC\Reader\AcroRd.exe';checksum=''}
    [pscustomobject]@{Name='adobereader';Path='C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe';checksum=''}
    [pscustomobject]@{Name='teamviewer';Path='C:\Program Files\TeamViewer\TeamViewer.exe';checksum=''}
    [pscustomobject]@{Name='teamviewer';Path='C:\Program Files (x86)\TeamViewer\TeamViewer.exe';checksum=''}
    [pscustomobject]@{Name='7zip';Path='C:\Program Files\7-Zip\7z.exe';checksum=''}
    [pscustomobject]@{Name='7zip';Path='C:\Program Files (x86)\7-Zip\7z.exe';checksum=''}
    [pscustomobject]@{Name='filezilla';Path='C:\Program Files\FileZilla FTP Client\filezilla.exe';checksum=''}
    [pscustomobject]@{Name='filezilla';Path='C:\Program Files (x86)\FileZilla FTP Client\filezilla.exe';checksum=''}
    [pscustomobject]@{Name='slack';Path='C:\Program Files\Slack\slack.exe';checksum=''}
    [pscustomobject]@{Name='slack';Path='C:\Program Files (x86)\Slack\slack.exe';checksum=''}
    [pscustomobject]@{Name='opera';Path='C:\Program Files\Opera\opera.exe';checksum=''}
    [pscustomobject]@{Name='opera';Path='C:\Program Files (x86)\Opera\opera.exe';checksum=''}
    [pscustomobject]@{Name='keepass';Path='C:\Program Files\KeePass Password Safe*';checksum=''}
    [pscustomobject]@{Name='keepass';Path='C:\Program Files (x86)\KeePass Password Safe*';checksum=''}
    [pscustomobject]@{Name='notepadplusplus';Path='C:\Program Files\Notepad++\notepad++.exe';checksum=''}
    [pscustomobject]@{Name='notepadplusplus';Path='C:\Program Files (x86)\Notepad++\notepad++.exe';checksum=''}
    [pscustomobject]@{Name='dropbox';Path='C:\Program Files\Dropbox\Client\Dropbox.exe';checksum=''}
    [pscustomobject]@{Name='dropbox';Path='C:\Program Files (x86)\Dropbox\Client\Dropbox.exe';checksum=''}
    [pscustomobject]@{Name='treesizefree';Path='C:\Program Files (x86)\JAM Software\TreeSize Free\TreeSizeFree.exe';checksum=''}
    [pscustomobject]@{Name='treesizefree';Path='C:\Program Files\JAM Software\TreeSize Free\TreeSizeFree.exe';checksum=''}
    [pscustomobject]@{Name='gimp';Path='C:\Program Files\GIMP*';checksum=''}
    [pscustomobject]@{Name='gimp';Path='C:\Program Files (x86)\GIMP*';checksum=''}
    [pscustomobject]@{Name='winscp';Path='C:\Program Files\WinSCP\WinSCP.exe';checksum=''}
    [pscustomobject]@{Name='winscp';Path='C:\Program Files (x86)\WinSCP\WinSCP.exe';checksum=''}
    [pscustomobject]@{Name='sql-server-management-studio';Path='C:\Program Files (x86)\Microsoft SQL Server Management Studio*';checksum=''}
    [pscustomobject]@{Name='sql-server-management-studio';Path='C:\Program Files\Microsoft SQL Server Management Studio*';checksum=''}
    [pscustomobject]@{Name='git';Path='C:\Program Files\Git\git-cmd.exe';checksum=''}
    [pscustomobject]@{Name='git';Path='C:\Program Files (x86)\Git\git-cmd.exe';checksum=''}
    [pscustomobject]@{Name='mysql.workbench';Path='C:\Program Files\MySQL\MySQL Workbench*';checksum=''}
    [pscustomobject]@{Name='mysql.workbench';Path='C:\Program Files (x86)\MySQL\MySQL Workbench*';checksum=''}
    [pscustomobject]@{Name='vlc';Path='C:\Program Files\VideoLAN\VLC\vlc.exe';checksum=''}
    [pscustomobject]@{Name='vlc';Path='C:\Program Files (x86)\VideoLAN\VLC\vlc.exe';checksum=''}
    [pscustomobject]@{Name='openoffice';Path='C:\Program Files (x86)\OpenOffice 4\program\swriter.exe';checksum=''}
    [pscustomobject]@{Name='nodejs';Path='C:\Program Files\nodejs\node.exe';checksum=''}
    [pscustomobject]@{Name='geforce-experience';Path='C:\Program Files\NVIDIA Corporation\NVIDIA GeForce Experience\NVIDIA GeForce Experience.exe';checksum=''}
    [pscustomobject]@{Name='zoom';Path='C:\Users\*\AppData\Roaming\Zoom\bin\Zoom.exe';checksum=''}
    [pscustomobject]@{Name='zoom';Path='C:\Program Files\Zoom\bin\Zoom.exe';checksum=''}
    [pscustomobject]@{Name='zoom';Path='C:\Program Files (x86)\Zoom\bin\Zoom.exe';checksum=''}
    [pscustomobject]@{Name='vmware-horizon-client';Path='C:\Program Files (x86)\VMware\VMware Horizon View Client\vmware-view.exe';checksum=''}
    [pscustomobject]@{Name='openssl';Path='C:\Program Files\OpenSSL-Win64\bin\openssl.exe';checksum=''}
    [pscustomobject]@{Name='wireshark';Path='C:\Program Files\Wireshark\Wireshark.exe';checksum=''}
    [pscustomobject]@{Name='putty';Path='C:\Program Files\PuTTY\putty.exe';checksum=''}
    [pscustomobject]@{Name='thunderbird';Path='C:\Program Files\Mozilla Thunderbird\thunderbird.exe';checksum=''}
)

#Add existing Applications from ref to choco
$localapps = choco.exe list

$remediated = 0
foreach ($updateref in $updaterefs) {
    $include = $true
    foreach ($localapp in $localapps) {
        if ($localapp.ToLower().Contains($updateref.Name.ToLower())) {
            Write-Output "found choco app $localapp"
            $include = $false
        }
    }
    if ($include -eq $true) { 
        if (Test-Path $updateref.Path) {
            Write-Output "found unmanaged app $($updateref.Name)"
            choco.exe install $updateref.Name --force -y $updateref.checksum
            $remediated = 1
        }
    }
}

#update existing Applications
choco.exe upgrade all -y
