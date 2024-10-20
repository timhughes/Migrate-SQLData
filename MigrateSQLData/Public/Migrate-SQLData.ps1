# Public/Migrate-SQLData.ps1

<#
.SYNOPSIS
    Migrates data from one SQL Server database to another.

.DESCRIPTION
    This function migrates data from a source SQL Server database to a destination
    SQL Server database. It supports SQL Server authentication and Windows authentication,
    data transformations, batching, transaction handling, and logging.

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
    The name of the transformation function to apply (from the "Transforms" folder).

.PARAMETER LogFilePath
    The path to the log file. Defaults to "MigrateSQLData_yyyyMMdd.log".

.PARAMETER BatchSize
    The batch size for bulk insert. Defaults to 1000.

.PARAMETER CommandTimeout
    The command timeout in seconds. Defaults to 30.

.PARAMETER Verbose
    Output verbose log messages.

.EXAMPLE
    Migrate-SQLData -SourceServer "SourceServer" -SourceDatabase "SourceDB" -SourceQuery "SELECT * FROM SourceTable" `
                    -DestinationServer "DestServer" -DestinationDatabase "DestDB" -DestinationTable "DestTable" `
                    -SourceWindowsAuthentication -DestinationWindowsAuthentication -TransformName "ToUpperTransform"

    This example migrates data from "SourceTable" in "SourceDB" on "SourceServer" to
    "DestTable" in "DestDB" on "DestServer" using Windows authentication and applies
    the "ToUpperTransform" transformation.

.NOTES
    Make sure the "Transforms" folder is in the same directory as the module.
    Transformation functions should accept a DataTable and return the modified DataTable.
#>
function Migrate-SQLData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceServer,

        [Parameter(Mandatory = $true)]
        [string]$SourceDatabase,

        [Parameter(Mandatory = $true)]
        [string]$SourceQuery,



        [Parameter(Mandatory = $true)]
        [string]$DestinationServer,

        [Parameter(Mandatory = $true)]
        [string]$DestinationDatabase,

        [Parameter(Mandatory = $true)]
        [string]$DestinationTable,

        [Parameter(Mandatory = false)]
        [string]$SourceUser,

        [Parameter(Mandatory = false)]
        [string]$SourcePassword,

        [Parameter(Mandatory = false)]
        [switch]$SourceWindowsAuthentication,

        [Parameter(Mandatory = false)]
        [string]$DestinationUser,

        [Parameter(Mandatory = false)]
        [string]$DestinationPassword,

        [Parameter(Mandatory = false)]
        [switch]$DestinationWindowsAuthentication,

        [Parameter(Mandatory = false)]
        [string]$TransformName = "None",  # Default: no transformation

        [Parameter(Mandatory = false)]
        [string]$LogFilePath = "MigrateSQLData_{0}.log",  # Default log file path with date formatting

        [Parameter(Mandatory = false)]
        [int]$BatchSize = 1000,  # Default batch size

        [Parameter(Mandatory = false)]
        [int]$CommandTimeout = 30,  # Default command timeout in seconds

        [Parameter(Mandatory = false)]
        [switch]$Verbose  # Verbose logging switch
    )

    # Start logging with date in the file name
    $LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogFilePath = $LogFilePath -f (Get-Date -Format "yyyyMMdd") # Format the date as yyyyMMdd

    # Define logging functions
    $LogVerbose = if ($Verbose) { { param($Message) Add-Content -Path $LogFilePath -Value "[$LogTime] $Message" } } else { { } } # Empty scriptblock if not verbose
    $Log = { param($Message) Add-Content -Path $LogFilePath -Value "[$LogTime] $Message" }

    # Log start message
    & $Log "Starting data migration..."

    # Get start time for performance metrics
    $StartTime = Get-Date

    try {
        # Collect initial performance counter values
        $InitialCpuTime = (Get-Counter -Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
        $InitialMemory = (Get-Counter -Counter "\Memory\Available MBytes").CounterSamples.CookedValue

        $SourceConnection = Get-SqlConnection -Server $SourceServer -Database $SourceDatabase -User $SourceUser -Password $SourcePassword -WindowsAuthentication $SourceWindowsAuthentication
        & $LogVerbose "Connected to source server: $SourceServer"

        $SourceData = Get-SQLData -Connection $SourceConnection -Query $SourceQuery
        & $LogVerbose "Extracted data from source database using query: $SourceQuery"
        & $LogVerbose "Number of rows to process: $($SourceData.Rows.Count)"

        $TransformedData = Invoke-DataTransformation -DataTable $SourceData -TransformName $TransformName
        if ($TransformName -ne "None") {
            & $LogVerbose "Applied transformation: $TransformName"
        }

        $DestinationConnection = Get-SqlConnection -Server $DestinationServer -Database $DestinationDatabase -User $DestinationUser -Password $DestinationPassword -WindowsAuthentication $DestinationWindowsAuthentication
        & $LogVerbose "Connected to destination server: $DestinationServer"

        Write-SQLData -Connection $DestinationConnection -Table $DestinationTable -DataTable $TransformedData -BatchSize $BatchSize -CommandTimeout $CommandTimeout
        & $LogVerbose "Inserted data into destination table: $DestinationTable"

        # Collect final performance counter values
        $FinalCpuTime = (Get-Counter -Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
        $FinalMemory = (Get-Counter -Counter "\Memory\Available MBytes").CounterSamples.CookedValue

        # Calculate performance metrics
        $EndTime = Get-Date
        $ElapsedTime = ($EndTime - $StartTime).TotalSeconds
        $AvgCpuUsage = ($FinalCpuTime + $InitialCpuTime) / 2
        $MemoryUsed = $InitialMemory - $FinalMemory

        # Log performance metrics
        & $Log "Migration completed successfully!"
        & $Log "Elapsed Time: $ElapsedTime seconds"
        & $Log "Average CPU Usage: $AvgCpuUsage%"
        & $Log "Memory Used: $MemoryUsed MB"

        # Publish performance metrics to Windows Performance Monitor
        $CounterData = @{
            CounterSetName = "SQL Data Migration"
            CounterName = "Rows Processed"
            InstanceName = "$SourceServer-$SourceDatabase-$SourceTable"
            Value = $SourceData.Rows.Count
        }
        New-Counter -CounterData $CounterData

        $CounterData = @{
            CounterSetName = "SQL Data Migration"
            CounterName = "Elapsed Time (seconds)"
            InstanceName = "$SourceServer-$SourceDatabase-$SourceTable"
            Value = $ElapsedTime
        }
        New-Counter -CounterData $CounterData

        $CounterData = @{
            CounterSetName = "SQL Data Migration"
            CounterName = "Average CPU Usage (%)"
            InstanceName = "$SourceServer-$SourceDatabase-$SourceTable"
            Value = $AvgCpuUsage
        }
        New-Counter -CounterData $CounterData

        $CounterData = @{
            CounterSetName = "SQL Data Migration"
            CounterName = "Memory Used (MB)"
            InstanceName = "$SourceServer-$SourceDatabase-$SourceTable"
            Value = $MemoryUsed
        }
        New-Counter -CounterData $CounterData

        Write-Host "Data migration completed successfully!"
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Add-Content -Path $LogFilePath -Value "[$LogTime] ERROR: $ErrorMessage"
        Write-Error $ErrorMessage
    }
    finally {
        if ($SourceConnection -ne $null) { $SourceConnection.Close() }
        if ($DestinationConnection -ne $null) { $DestinationConnection.Close() }
    }
}
