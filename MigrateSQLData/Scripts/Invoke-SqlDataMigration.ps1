# Invoke-SqlDataMigration.ps1

<#
.SYNOPSIS
    Migrates data from one SQL Server database to another.

.DESCRIPTION
    This script is a wrapper around the Copy-SQLData function. It can load
    migration settings from a configuration file or accept parameters directly.

.PARAMETER ConfigFile
    The path to the configuration file (optional). If specified, other parameters
    will be loaded from this file.

.PARAMETER SourceServer
    The name or IP address of the source SQL Server.

.PARAMETER SourceDatabase
    The name of the source database.

.PARAMETER SourceQuery
    The SQL query to execute on the source database.

.PARAMETER DestinationServer
    The name or IP address of the destination SQL Server.

.PARAMETER DestinationDatabase
    The name of the destination database.

.PARAMETER DestinationTable
    The name of the destination table.

.PARAMETER SourceUser
    The username for SQL Server authentication on the source server (if not using Windows authentication).

.PARAMETER SourcePassword
    The password for SQL Server authentication on the source server (if not using Windows authentication).

.PARAMETER SourceWindowsAuthentication
    Use Windows authentication for the source server connection.

.PARAMETER DestinationUser
    The username for SQL Server authentication on the destination server (if not using Windows authentication).

.PARAMETER DestinationPassword
    The password for SQL Server authentication on the destination server (if not using Windows authentication).

.PARAMETER DestinationWindowsAuthentication
    Use Windows authentication for the destination server connection.

.PARAMETER TransformName
    The name of the transformation to apply.

.EXAMPLE
    # Using a configuration file
    .\Invoke-SqlDataMigration.ps1 -ConfigFile ".\Config\migration_instance1.psd1"

    # Specifying parameters directly
    .\Invoke-SqlDataMigration.ps1 -SourceServer "MySourceServer" -SourceDatabase "MySourceDB" -SourceQuery "SELECT * FROM MyTable" `
                  -DestinationServer "MyDestServer" -DestinationDatabase "MyDestDB" -DestinationTable "MyDestTable" `
                  -SourceWindowsAuthentication -DestinationWindowsAuthentication -TransformName "ToUpperTransform"
#>

function Invoke-SqlDataMigration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ConfigFile,

        [Parameter(Mandatory = $false)]
        [string]$SourceServer,

        [Parameter(Mandatory = $false)]
        [string]$SourceDatabase,

        [Parameter(Mandatory = $false)]
        [string]$SourceQuery,

        [Parameter(Mandatory = $false)]
        [string]$DestinationServer,

        [Parameter(Mandatory = $false)]
        [string]$DestinationDatabase,

        [Parameter(Mandatory = $false)]
        [string]$DestinationTable,

        [Parameter(Mandatory = $false)]
        [string]$SourceUser,

        [Parameter(Mandatory = $false)]
        [string]$SourcePassword,

        [Parameter(Mandatory = $false)]
        [switch]$SourceWindowsAuthentication,

        [Parameter(Mandatory = $false)]
        [string]$DestinationUser,

        [Parameter(Mandatory = $false)]
        [string]$DestinationPassword,

        [Parameter(Mandatory = $false)]
        [switch]$DestinationWindowsAuthentication,

        [Parameter(Mandatory = $false)]
        [string]$TransformName
    )

    # Load settings from the configuration file if provided
    if ($ConfigFile) {
        $settings = Import-PowerShellDataFile -Path "$ConfigFile"
        $SourceServer = $settings.SourceServer
        $SourceDatabase = $settings.SourceDatabase
        $SourceQuery = $settings.SourceQuery
        $DestinationServer = $settings.DestinationServer
        $DestinationDatabase = $settings.DestinationDatabase
        $DestinationTable = $settings.DestinationTable
        $SourceWindowsAuthentication = $settings.SourceWindowsAuthentication
        $DestinationWindowsAuthentication = $settings.DestinationWindowsAuthentication
        $TransformName = $settings.TransformName
        $LogFilePath = $settings.LogFilePath
        $BatchSize = $settings.BatchSize
        $CommandTimeout = $settings.CommandTimeout
        $Verbose = $settings.Verbose
    }

    # Import the module
    Import-Module MigrateSQLData

    # Construct a prompt message
    $promptMessage = "Are you sure you want to migrate data from '{0}'.'{1}' to '{2}'.'{3}'? (y/n)" -f $SourceServer, $SourceDatabase, $DestinationServer, $DestinationDatabase

    # Confirm before proceeding with the migration
    if (-not (Read-Host -Prompt $promptMessage -AsSecureString) -match "^y") {
        Write-Host "Migration cancelled."
        return
    }

    # Call the Copy-SQLData function with the provided parameters
    Copy-SQLData -SourceServer $SourceServer `
                    -SourceDatabase $SourceDatabase `
                    -SourceQuery $SourceQuery `
                    -DestinationServer $DestinationServer `
                    -DestinationDatabase $DestinationDatabase `
                    -DestinationTable $DestinationTable `
                    -SourceWindowsAuthentication:$SourceWindowsAuthentication `
                    -DestinationWindowsAuthentication:$DestinationWindowsAuthentication `
                    -TransformName $TransformName `
                    -LogFilePath $LogFilePath `
                    -BatchSize $BatchSize `
                    -CommandTimeout $CommandTimeout `
                    -Verbose:$Verbose
}
