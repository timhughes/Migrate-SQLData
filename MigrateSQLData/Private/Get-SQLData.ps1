# Private/Get-SQLData.ps1

<#
.SYNOPSIS
    Retrieves data from a SQL Server database using a specified query.

.DESCRIPTION
    This function executes a SQL query against a specified database and returns
    the results in a DataTable.

.PARAMETER Connection
    The SqlConnection object.

.PARAMETER Query
    The SQL query to execute.

.RETURNS
    A DataTable object containing the query results.

.EXAMPLE
    # Example: Execute a custom query
    $query = "SELECT Column1, Column2 FROM TableName WHERE Column3 = 'SomeValue'"
    $data = Get-SQLData -Connection $connection -Query $query

.NOTES
    The "Query" parameter is mandatory.
#>
function Get-SQLData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Data.SqlClient.SqlConnection]$Connection,

        [Parameter(Mandatory = $true)]
        [string]$Query
    )

    try {
        $Command = New-Object System.Data.SqlClient.SqlCommand($Query, $Connection)

        $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter($Command)
        $DataTable = New-Object System.Data.DataTable


        $Adapter.Fill($DataTable)
        return $DataTable
    }
    catch {
        Write-Error "Failed to execute query: $($_.Exception.Message)"
        throw
    }
}
