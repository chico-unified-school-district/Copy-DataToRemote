# Copy-DataToRemote

## Overview

**Copy-DataToRemote.ps1** is a PowerShell script template for automating the extraction of data from a SQL Server database and securely transferring the resulting file to a remote server via SFTP. This script is intended for vendor student data uploads and similar data transfer tasks.

---

## Features

- Extracts data from SQL Server using a custom query
- Exports results to CSV and removes double quotes for compatibility
- Securely transfers the file to a remote server via SFTP
- Cleans up local export files after transfer
- Modular functions for easy customization

---

## Prerequisites

- PowerShell 5.1 or later
- The following PowerShell modules:
  - `CommonScriptFunctions` (for SQL operations)
  - `dbatools` (for database connectivity)
  - `Posh-SSH` (for SFTP file transfer)
- Network access to both SQL Server and SFTP server
- Appropriate credentials for SQL Server and SFTP

---

## Usage

1. **Prepare your SQL query** and save it as a `.sql` file.
2. **Open PowerShell** and navigate to the script directory.
3. **Run the script** with the required parameters:

```powershell
$sqlCred = Get-Credential -Message "Enter SQL Server credentials"
$sftpCred = Get-Credential -Message "Enter SFTP credentials"

.\Copy-DataToRemote.ps1 `
    -SQLServer "sqlserver.example.com" `
    -SQLDatabase "StudentDB" `
    -SQLCredential $sqlCred `
    -SQLQuery ".\sql\student_export.sql" `
    -RemoveDoubleQuotes `
    -SftpServer "sftp.vendor.com" `
    -SftpPort 4545 `
    -SftpCredential $sftpCred `
    -ExportName "students.csv" `
    -RemoteDirectory "/incoming"
```

---

## Parameters

| Name                 | Type                 | Description                              |
| -------------------- | -------------------- | ---------------------------------------- |
| `SQLServer`          | `string`             | SQL Server instance name or address      |
| `SQLDatabase`        | `string`             | Name of the database to query            |
| `SQLCredential`      | `PSCredential`       | SQL Server authentication credentials    |
| `SQLQuery`           | `string` (file path) | Path to the SQL query file               |
| `SQLQueryStatement`  | `string`             | SQL query statement as a string          |
| `SftpServer`         | `string`             | SFTP server hostname or IP               |
| `SftpPort`           | `int` (optional)     | SFTP server port (default is 22)         |
| `SftpCredential`     | `PSCredential`       | SFTP authentication credentials          |
| `ExportName`         | `string`             | Name for the exported CSV file           |
| `RemoteDirectory`    | `string`             | Destination directory on the SFTP server |
| `RemoveDoubleQuotes` | `switch` (optional)  | Remove double quotes from the CSV file   |
| `WhatIf`             | `switch` (optional)  | Preview actions without executing them   |

---

## Process Flow

1. **Imports required modules**
2. **Creates a local `.\data\` directory** for exports
3. **Reads and executes the SQL query**
4. **Exports results to CSV and removes double quotes**
5. **Transfers the file to the remote SFTP server**
6. **Deletes the local export file after transfer**

---

## Security Notes

- Credentials are handled securely using PowerShell's `Get-Credential`.
- SFTP transfers use port 22 and accept the host key automatically.
- Local export files are deleted after transfer to minimize data exposure.

---

## Troubleshooting

- Ensure all required modules are installed and imported.
- Verify network connectivity to both SQL Server and SFTP server.
- Check permissions for both database access and SFTP upload.
- Review error messages for details if the script fails.

---

## Disclaimer

This script is provided as a template and example. Please review and test thoroughly before using in production. Use at your own risk.

---
