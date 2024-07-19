# Description
- This repo focuses on pulling all the VM details, VMHost details, Vsan Performance details, and Health details of the cluster on which your VMs and Hosts are.


# Install Powershell using brew (On MacOS): 
- brew install powershell/tap/powershell
- pwsh (to enter into powershell)

# Install Powershell on Linux:
- You can explore "https://developer.broadcom.com/powercli/installation-guide"

# Install PowerCLI from within powershell

- Install-Module -Name VMware.PowerCLI
- Get-Module -Name VMware.PowerCLI -ListAvailable   (to verify installation)
- Import-Module VMware.PowerCLI

# Connect to Vcenter server
- Connect-VIServer -Server "IP address of your server" -User "Your username" -Password "Your password"
- If you get SSL error, then follow the below commands.

        1)  Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force -AllowClobber

        2) Add-Type @"
        using [System.Net](http://system.net/);
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
        }}"
        @[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        
        3)  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        4)  Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
        
        5)  Connect-VIServer -Server "IP address of your server" -User "Your username" -Password "Your password"
            


Now you are all set to run the main.ps1 file and you can edit as per your needs. 
