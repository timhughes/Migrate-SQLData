# Config/migration_instance1.psd1
<#
.SYNOPSIS
    Example configuration settings for SQL data migration instance 1.

.DESCRIPTION
    This file contains the configuration parameters for migrating data from
    a source SQL Server database to a destination SQL Server database
    for instance 1.

    The parameters include source and destination server details, authentication
    options, transformation settings, logging preferences, and performance tuning
    options.
#>

@{

    # Source SQL Server details
    SourceServer = "YourSourceServer1"
    SourceDatabase = "YourSourceDatabase1"
    SourceQuery = "SELECT * FROM YourSourceTable"

    # Destination SQL Server details
    DestinationServer = "YourDestinationServer1"
    DestinationDatabase = "YourDestinationDatabase1"
    DestinationTable = "YourDestinationTable1"

    # Authentication (choose one option for source and destination)
    # Option 1: Windows Authentication
    SourceWindowsAuthentication = $true
    DestinationWindowsAuthentication = $true

    # Option 2: SQL Server Authentication (if not using Windows Authentication)
    # SourceUser = "YourSourceUser"
    # SourcePassword = "YourSourcePassword"
    # DestinationUser = "YourDestinationUser"
    # DestinationPassword = "YourDestinationPassword"

    # Transformation (optional)
    TransformName = "ToUpperTransform"  # Name of the transformation function

    # Other settings
    LogFilePath = "MigrateSQLData_Instance1_{0}.log" # Log file path with date and instance identifier
    BatchSize = 5000  # Number of rows to insert in each batch
    CommandTimeout = 60  # Timeout for SQL commands in seconds
    Verbose = $false   # Whether to output verbose logs
}
