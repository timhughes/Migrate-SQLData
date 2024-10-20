<#
.SYNOPSIS
    Creates a SQL Server database connection.

.DESCRIPTION
    This function creates a connection to a SQL Server database using either
    SQL Server authentication or Windows authentication.

.PARAMETER Server
    The name or IP address of the SQL Server.

.PARAMETER Database
    The name of the database.

.PARAMETER User
    The username for SQL Server authentication (if not using Windows authentication).

.PARAMETER Password
    The password for SQL Server authentication (if not using Windows authentication).

.PARAMETER WindowsAuthentication
    Use Windows authentication for the connection.

.RETURNS
    A SqlConnection object.

.EXAMPLE
    $connection = Get-SqlConnection -Server "ServerName" -Database "DBName" -WindowsAuthentication

    This example creates a connection to the "DBName" database on "ServerName"
    using Windows authentication.
#>
function Get-SqlConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [string]$Database,

        [Parameter(Mandatory = false)]
        [string]$User,

        [Parameter(Mandatory = false)]
        [string]$Password,

        [Parameter(Mandatory = false)]
        [switch]$WindowsAuthentication
    )

    try {
        $Connection = New-Object System.Data.SqlClient.SqlConnection

        if ($WindowsAuthentication) {
            $Connection.ConnectionString = "Server=$Server;Database=$Database;Integrated Security=True"
        }
        else {
            if (-not $User -or -not $Password) {
                throw "User and Password are required when not using Windows Authentication."
            }
            $Connection.ConnectionString = "Server=$Server;Database=$Database;User ID=$User;Password=$Password"
        }

        $Connection.Open()
        return $Connection
    }
    catch {
        Write-Error "Failed to connect to server '$Server': $($_.Exception.Message)"
        throw
    }
}
