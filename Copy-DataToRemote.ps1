# Framework: Powershell CUSD template for vendor student data upload
# This is just a sample template to serve as an example of how SQL and SFTP tasks can be automated.
# Please familiarize yourself with the code and packages and use at your own risk
# Extract file(s) and send via SFTP
[cmdletbinding()]
param (
 [Parameter(Mandatory = $True)][string]$SQLServer,
 [Parameter(Mandatory = $True)][string]$SQLDatabase,
 [Parameter(Mandatory = $True)][System.Management.Automation.PSCredential]$SQLCredential,
 [Parameter(Mandatory = $False)][string]$SQLQueryFile,
 [Parameter(Mandatory = $False)][string]$SQLQueryStatement,
 [Parameter(Mandatory = $False)][switch]$RemoveDoubleQuotes,
 [Parameter(Mandatory = $True)][string]$SftpServer,
 [Parameter(Mandatory = $False)][int]$SftpPort = 22,
 [Parameter(Mandatory = $True)][System.Management.Automation.PSCredential]$SftpCredential,
 [Parameter(Mandatory = $True)][string]$ExportName,
 [Parameter(Mandatory = $True)][string]$RemoteDirectory,
 [Alias('wi')][switch]$WhatIf
)

function Copy-ExportToRemote ($server, $port, $user, $exportPath, $destinationDirectory) {
 try {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  $Session = New-SFTPSession -ComputerName $server -Credential $user -Port $port -AcceptKey
  Set-SFTPItem -SessionId $Session.SessionId -Path $exportPath -Destination $destinationDirectory -Force -Verbose
 }
 catch {
  Write-Error "SFTP Transfer Failed: $($_.Exception.Message)"
  exit 1
 }
 finally {
  # Disconnect, clean up
  Remove-SFTPSession -SessionId $Session.SessionId
 }
}

function Get-Data ($params) {
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  New-SqlOperation @sqlParams
 }
}

function New-DataDir ($dataPath) {
 if (Test-Path -Path $dataPath) { return }
 New-Item -Path $dataPath -ItemType Directory -Confirm:$false -Force
}

function Remove-DoubleQuotes ($filePath) {
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  $csvContent = Get-Content -Path $filePath -Raw
  # Remove double quotes from the CSV content
  $csvContent = $csvContent.Replace('"', '')
  Write-Host "Double quotes removed from '$filePath'."
  # Write the modified content back to the CSV file
  Set-Content -Path $filePath -Value $csvContent -Encoding UTF8
 }
}

# ==================== Main =====================

# Imported Functions
Import-Module -Name CommonScriptFunctions -Cmdlet New-SqlOperation, Show-BlockInfo
Import-Module -Name dbatools -Cmdlet Invoke-DbaQuery, Set-DbatoolsConfig, Connect-DbaInstance, Disconnect-DbaInstance
Import-Module -Name Posh-SSH -Cmdlet New-SFTPSession, Set-SFTPItem, Remove-SFTPSession

$outPath = '.\data\'
New-DataDir $outPath

$fullExportPath = (Join-Path -Path $outPath -ChildPath $ExportName)

$query = if ($SQLQueryFile) { Get-Content -Path $SQLQueryFile -Raw }
elseif ($SQLQueryStatement) { $SQLQueryStatement }
else { throw 'Either SQLQueryFile or SQLQueryStatement must be provided.' }

$sqlParams = @{
 Server     = $SQLServer
 Database   = $SQLDatabase
 Credential = $SQLCredential
 Query      = $query
}

Get-Data $sqlParams | Export-Csv -NoTypeInformation -Path $fullExportPath

if ($RemoveDoubleQuotes) { Remove-DoubleQuotes -FilePath $fullExportPath }

Copy-ExportToRemote $SftpServer $SftpPort $SftpCredential $fullExportPath $RemoteDirectory
Remove-Item -Path $fullExportPath -Confirm:$false -Force