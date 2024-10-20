<#
.SYNOPSIS
    Writes data to a SQL Server table.

.DESCRIPTION
    This function writes data from a DataTable to a specified table in a
    SQL Server database using SqlBulkCopy.

.PARAMETER Connection
    The SqlConnection object.

.PARAMETER Table
    The name of the table.

.PARAMETER DataTable
    The DataTable containing the data to be written.

.PARAMETER BatchSize
    The batch size for bulk insert. Defaults to 1000.

.PARAMETER CommandTimeout
    The command timeout in seconds. Defaults to 30.

.EXAMPLE
    Write-SQLData -Connection $connection -Table "TableName" -DataTable $data

    This example writes data from the $data DataTable to the "TableName" table
    using the provided $connection object.
#>
function Write-SQLData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Data.SqlClient.SqlConnection]$Connection,

        [Parameter(Mandatory = $true)]
        [string]$Table,

        [Parameter(Mandatory = $true)]
        [System.Data.DataTable]$DataTable,

        [Parameter(Mandatory = false)]
        [int]$BatchSize = 1000,  # Default batch size

        [Parameter(Mandatory = false)]
        [int]$CommandTimeout = 30  # Default command timeout in seconds
    )

    try {
        $Transaction = $Connection.BeginTransaction()
        try {
            $BulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($Connection, ([System.Data.SqlClient.SqlBulkCopyOptions]::UseInternalTransaction), $Transaction)
            $BulkCopy.DestinationTableName = $Table
            $BulkCopy.BatchSize = $BatchSize
            $BulkCopy.BulkCopyTimeout = $CommandTimeout
            $BulkCopy.WriteToServer($DataTable)

            $Transaction.Commit()
        }
        catch {
            $Transaction.Rollback()
            Write-Error "Failed to insert data into table '$Table': $($_.Exception.Message)"
            throw
        }
    }
    catch {
        Write-Error "Failed to insert data into table '$Table': $($_.Exception.Message)"
        throw
    }
}
