# Migrate-SQLData.psd1

@{

    # Module metadata
    ModuleVersion = '1.0.0'
    GUID = '25fa4824-90ab-11ef-b4e5-d45d64d442bb' # Generate a new GUID
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Copyright = '(c) Year Your Name. All rights reserved.'
    Description = 'Migrates data between SQL Server databases.'

    # Version compatibility
    PowerShellVersion = '5.1'
    DotNetFrameworkVersion = '4.5'

    # Module dependencies (if any)
    # RequiredModules = @('OtherModule')

    # Files to include in the module
    RootModule = 'MigrateSQLData.psm1'
    #ModuleToProcess = 'Migrate-SQLData.psm1'
    PrivateData = @{
        PSData = @{
            # Tags for the PowerShell Gallery (if publishing)
            # Tags = @('SQL', 'Migration', 'Data')

            # External module dependencies
            # PSData = @{
            #     DependsOn = @('OtherModule')
            # }
        }
    }

    # Functions to export
    FunctionsToExport =  @(
        'COpy-SQLData',
        'Invoke-SqlDataMigration'
    )

    # Cmdlets to export (if any)
    # CmdletsToExport = '*'

    # Variables to export (if any)
    # VariablesToExport = '*'

    # Aliases to export (if any)
    # AliasesToExport = '*'

    # Nested modules (if any)
    # NestedModules = @('OtherModule.psm1')
}
