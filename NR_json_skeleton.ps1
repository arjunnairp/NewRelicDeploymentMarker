# Created on 3 May 2018
<#
.SYNOPSIS
    .Push Deployment Notes to New Relic during Production Releases
.NOTES
	File Name	: NR_json.ps1
	Author		: Arjun N
	Version		: 1.1
	Requires	: Powershell.
	Changes		: Updated to include logic for Search only releases 11-May-2018
				  Added Web Client Object to force PS to use current user credentials to authenticate on proxy server 15-May-2018
#>

#Declare variables with process details.
$revision = Read-Host -Prompt 'Provide the RFC Number in the format RFCxxxxxx:'
$description = Read-Host -Prompt 'Input Name of RFC:'
$changelog = Read-Host -Prompt 'Enter the change log in a single line. Typically the resolution field of RFC'
$user = Read-Host -Prompt 'Provide your email id here:'


# Create the Web Client object
$browser = New-Object System.Net.WebClient
# Tell it to use our default creds for the proxy
$browser.Proxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials 

$bodyvalue = @{"deployment" = @{"revision" = ${revision}; "changelog" = ${changelog}; "description" = ${description};  "user" = ${user}}}
$jsonbody = ConvertTo-Json $bodyvalue
Write-Host $jsonbody

Write-Host "Which servers are involved in the release?"
$Srv = Read-Host "`n1. Web & Search servers `n2. Web servers only `n3. Search servers only`nEnter 1 or 2 or 3 "

#$Srv = Read-Host -Prompt 'Are Search servers(TCSVRWEB11-16) involved in the release?(Y/N)'

Write-Host "Starting the script for Deplyoment Marker"
#Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 

if ($Srv -eq '2')
{ 

# New Relic Web application
Invoke-WebRequest -Uri https://api.newrelic.com/v2/applications/1234567/deployments.json -Method POST -Headers @{'X-Api-Key'=''} -ContentType 'application/json' -Body $jsonbody

    Write-Host "Deployment Marked on Web servers only"
	Write-Host ""${user}" input "${revision}" with description "${description}" and change log "${changelog}" on Web servers only." 
	
}

elseif ($Srv -eq '3')
{ 

# New Relic Web application
Invoke-WebRequest -Uri https://api.newrelic.com/v2/applications/2345678/deployments.json -Method POST -Headers @{'X-Api-Key'=''} -ContentType 'application/json' -Body $jsonbody

    Write-Host "Deployment Marked on Search servers only"
	Write-Host ""${user}" input "${revision}" with description "${description}" and change log "${changelog}" on Search servers only." 
	
}

else
{
# New Relic Web application
Invoke-WebRequest -Uri https://api.newrelic.com/v2/applications/1234567/deployments.json -Method POST -Headers @{'X-Api-Key'=''} -ContentType 'application/json' -Body $jsonbody
	
# New Relic SearchWeb application    
Invoke-WebRequest -Uri https://api.newrelic.com/v2/applications/2345678/deployments.json -Method POST -Headers @{'X-Api-Key'=''} -ContentType 'application/json' -Body $jsonbody

    Write-Host "Deployment Marked on Web and Search servers"
	Write-Host ""${user}" input "${revision}" with description "${description}" and change log "${changelog}" on both Web and Search servers." 
}

    Write-Host "Script ended & Deployments marked"
## Script ends.