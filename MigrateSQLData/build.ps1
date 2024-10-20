# build.ps1

<#
.SYNOPSIS
    Builds, tests, and deploys the SQL data migration project.

.DESCRIPTION
    This script automates the build process for the SQL data migration project.
    It supports the following tasks:

    * Test: Runs the Pester unit tests.
    * Deploy: Copies the module and transform scripts to the target environment.
    * Migrate: Executes the data migration process.

.PARAMETER ConfigFile
    The path to the configuration file (optional). If not specified, the "Migrate"
    task will be skipped.

.PARAMETER Task
    The task to perform. Defaults to "Migrate". Valid values are:
    "Test", "Deploy", "Migrate".

.EXAMPLE
    .\build.ps1 -Task Test

    This example runs the unit tests.

    .\build.ps1 -ConfigFile ".\Config\migration_instance1.psd1"

    This example runs the data migration using the settings in "migration_instance1.psd1".
#>

Param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile,

    [Parameter(Mandatory = $false)]
    [string]$Task = "Migrate"  # Default task is "Migrate"
)

# Test task to run Pester tests
function Test {
    Invoke-Pester .\Tests\MigrateSQLData.Tests.ps1
}

# Deploy task to copy files to the target environment
function Deploy {
    Test  # Call the Test function first

    # Create the target directory if it doesn't exist
    $targetDir = "C:\Target\Directory"
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir | Out-Null
    }

    # Copy the module and transform scripts to the target environment
    Copy-Item ".\Public\*" -Destination $targetDir -Recurse
    Copy-Item ".\Transforms\*" -Destination (Join-Path $targetDir "Transforms") -Recurse
}

# Migrate task to execute the data migration
function Migrate {
    Deploy  # Call the Deploy function first

    # Load project settings if ConfigFile is provided
    if ($ConfigFile) {
        $settings = Import-PowerShellDataFile -Path ".\Config\$ConfigFile"
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
    } else {
        Write-Warning "No configuration file specified. Skipping data migration."
        return
    }

    # Construct a more specific prompt message
    $promptMessage = "Are you sure you want to migrate data from '{0}'.'{1}' to '{2}'.'{3}'? (y/n)" -f $SourceServer, $SourceDatabase, $DestinationServer, $DestinationDatabase

    # Confirm before proceeding with the migration
    if (-not (Read-Host -Prompt $promptMessage -AsSecureString) -match "^y") {
        Write-Host "Migration cancelled."
        return
    }

    # Run the Migrate-SQLData function with the specified parameters
    Import-Module (Join-Path "C:\Target\Directory" "MigrateSQLData.psm1")
    Migrate-SQLData -SourceServer $SourceServer `
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

# Invoke the specified task
switch ($Task) {
    "Test" { Test }
    "Deploy" { Deploy }
    "Migrate" { Migrate }
    default {
        Write-Error "Invalid task specified: $Task"
    }
}
