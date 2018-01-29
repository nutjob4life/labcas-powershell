# =============================================================
# Windows PowerShell example to download data from LabCAS's API
# =============================================================


# Set up username and password
# ----------------------------

$labcas_username = "YOUR-USERNAME"
$labcas_password = "YOUR-PASSWORD"
$pair = "${labcas_username}:${labcas_password}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuth = "Basic $base64"
$headers = @{ Authorization = $basicAuth }


# Set up networking
# -----------------

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem
        ) {
            return true;
        }
    }
"@
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


# Get a list of files for dataset "Team_37_CTIIP_Animal_Models.CTIIP-1.1c"
# ------------------------------------------------------------------------
#
# You could put in your own query here. See 
# https://oodt.jpl.nasa.gov/wiki/display/edrn/LabCAS+APIs
# for examples.

$response = Invoke-WebRequest -Uri "https://mcl-labcas.jpl.nasa.gov/data-access-api/files/download?wt=json&indent=true&q=Team_37_CTIIP_Animal_Models.CTIIP-1.1c" -Headers $headers -OutFile files.csv

Import-Csv -Path files.csv -Header URL | ForEach-Object {
    $url = $_.URL
    $filename = $url.Substring($url.LastIndexOf("/") + 1)
    Write-Output "Downloading $filename"
    $response = Invoke-WebRequest -Uri $url -Headers $headers -Outfile $filename -SessionVariable cookie_jar
}

