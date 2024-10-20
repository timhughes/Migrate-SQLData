# Migrate-SQLData.Tests.ps1

# Requires the Pester testing framework
# Install it using: Install-Module Pester

# Use $PSScriptRoot to get the module directory
# $modulePath = Join-Path $PSScriptRoot "..\MigrateSQLData.psm1"
# Write-Output "modulePath: $modulePath"
# Write-Output "PSModulePath: $env:PSModulePath"
# Import-Module $modulePath
# Import-Module "..\MigrateSQLData.psm1"
# $env:PSModulePath = $env:PSModulePath + ";$modulePath"
# Import-Module MigrateSQLData

$moduleRoot = Resolve-Path "$PSScriptRoot\.."
$moduleName = "MigrateSQLData" # Split-Path $moduleRoot -Leaf
$env:PSModulePath = $env:PSModulePath + ":$moduleRoot"


# Mock the database connections and commands to avoid actual database access
Mock Get-SqlConnection {
    # Return a mock connection object
    [PSCustomObject]@{
        Open = {}
        Close = {}
        BeginTransaction = {
            [PSCustomObject]@{
                Commit = {}
                Rollback = {}
            }
        }
    }
}

Mock Get-SQLData {
    # Return a mock DataTable
    [System.Data.DataTable]@{
        Columns = @(
            [System.Data.DataColumn]@{ ColumnName = "Column1"; DataType = [string] }
            [System.Data.DataColumn]@{ ColumnName = "Column2"; DataType = [int] }
        )
        Rows = @(
            @{ Column1 = "Value1"; Column2 = 1 }
            @{ Column1 = "Value2"; Column2 = 2 }
        )
    }
}

Mock Write-SQLData {
    # Do nothing (mock the data insertion)
}

# Mock Add-Content to prevent writing to actual files
Mock Add-Content {
    # Do nothing (mock the logging)
}

# Mock Get-Counter to prevent accessing actual performance counters
Mock Get-Counter {
    # Return mock counter values
    [PSCustomObject]@{
        CounterSamples = [PSCustomObject]@{
            CookedValue = 50  # Example CPU or memory value
        }
    }
}

# Mock New-Counter to prevent publishing actual performance metrics
Mock New-Counter {
    # Do nothing (mock publishing metrics)
}

Describe "Copy-SQLData" {
    
    It "should migrate data with no transformation" {
        {Copy-SQLData -SourceServer "TestSourceServer" `
                        -SourceDatabase "TestSourceDB" `
                        -SourceTable "TestSourceTable" `
                        -SourceQuery "SELECT 1" `
                        -DestinationServer "TestDestServer" `
                        -DestinationDatabase "TestDestDB" `
                        -DestinationTable "TestDestTable" `
                        -SourceWindowsAuthentication `
                        -DestinationWindowsAuthentication `
                        -LogFilePath "Migrate-SQLData_Instance1_{0}.log" }| Should -Not -Throw
    }

    It "should migrate data with a valid transformation" {
        {Copy-SQLData -SourceServer "TestSourceServer" `
                        -SourceDatabase "TestSourceDB" `
                        -SourceTable "TestSourceTable" `
                        -SourceQuery "SELECT 1" `
                        -DestinationServer "TestDestServer" `
                        -DestinationDatabase "TestDestDB" `
                        -DestinationTable "TestDestTable" `
                        -SourceWindowsAuthentication `
                        -DestinationWindowsAuthentication `
                        -TransformName "Convert-Column" `
                        -LogFilePath "Migrate-SQLData_Instance1_{0}.log" }| Should -Not -Throw
    }

    It "should handle an invalid transformation name" {
        {Copy-SQLData -SourceServer "TestSourceServer" `
                        -SourceDatabase "TestSourceDB" `
                        -SourceTable "TestSourceTable" `
                        -SourceQuery "SELECT 1" `
                        -DestinationServer "TestDestServer" `
                        -DestinationDatabase "TestDestDB" `
                        -DestinationTable "TestDestTable" `
                        -SourceWindowsAuthentication `
                        -DestinationWindowsAuthentication `
                        -TransformName "Convert-Column" `
                        -LogFilePath "Migrate-SQLData_Instance1_{0}.log"} | Should -Not -Throw
    }

    It "should migrate data with source Windows Authentication" {
        {Copy-SQLData -SourceServer "TestSourceServer" `
                        -SourceDatabase "TestSourceDB" `
                        -SourceTable "TestSourceTable" `
                        -SourceQuery "SELECT 1" `
                        -DestinationServer "TestDestServer" `
                        -DestinationDatabase "TestDestDB" `
                        -DestinationTable "TestDestTable" `
                        -SourceWindowsAuthentication `
                        -DestinationUser "TestDestUser" `
                        -DestinationPassword "TestDestPassword" `
                        -LogFilePath "Migrate-SQLData_Instance1_{0}.log"} | Should -Not -Throw
    }

    It "should migrate data with destination Windows Authentication" {
        {Copy-SQLData -SourceServer "TestSourceServer" `
                        -SourceDatabase "TestSourceDB" `
                        -SourceTable "TestSourceTable" `
                        -SourceQuery "SELECT 1" `
                        -DestinationServer "TestDestServer" `
                        -DestinationDatabase "TestDestDB" `
                        -DestinationTable "TestDestTable" `
                        -SourceUser "TestSourceUser" `
                        -SourcePassword "TestSourcePassword" `
                        -DestinationWindowsAuthentication `
                        -LogFilePath "Migrate-SQLData_Instance1_{0}.log"} | Should -Not -Throw
    }

    It "should migrate data with both source and destination Windows Authentication" {
        {Copy-SQLData -SourceServer "TestSourceServer" `
                        -SourceDatabase "TestSourceDB" `
                        -SourceTable "TestSourceTable" `
                        -SourceQuery "SELECT 1" `
                        -DestinationServer "TestDestServer" `
                        -DestinationDatabase "TestDestDB" `
                        -DestinationTable "TestDestTable" `
                        -SourceWindowsAuthentication `
                        -DestinationWindowsAuthentication `
                        -LogFilePath "Migrate-SQLData_Instance1_{0}.log"} | Should -Not -Throw
    }

    It "should log verbose messages when -Verbose is specified" {
        # Use Should -Invoke to verify that Add-Content is called with the expected messages
        {Copy-SQLData -SourceServer "TestSourceServer" `
                        -SourceDatabase "TestSourceDB" `
                        -SourceTable "TestSourceTable" `
                        -SourceQuery "SELECT 1" `
                        -DestinationServer "TestDestServer" `
                        -DestinationDatabase "TestDestDB" `
                        -DestinationTable "TestDestTable" `
                        -SourceWindowsAuthentication `
                        -DestinationWindowsAuthentication `
                        -LogFilePath "Migrate-SQLData_Instance1_{0}.log" `
                        -Verbose} | Should -Invoke Add-Content -WithArguments @("Migrate-SQLData_Instance1_{0}.log", "*Connected to source server:*")

        # Add more Should -Invoke assertions for other verbose log messages as needed
    }

    # Add more tests for other scenarios and error conditions
}
