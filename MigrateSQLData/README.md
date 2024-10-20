# MigrateSQLData

This PowerShell module provides a function to migrate data from one SQL Server database to another. It supports various features like:

* **Authentication:** SQL Server Authentication and Windows Authentication
* **Transformations:** Apply custom transformations to the data during migration.
* **Batching:**  Efficiently migrate large datasets using `SqlBulkCopy`.
* **Transactions:** Ensure data integrity with transaction support.
* **Logging:**  Detailed logging of the migration process.
* **Performance Metrics:**  Capture and publish performance metrics.
* **Configuration:**  Use configuration files for different migration instances.

## File Structure
```
MigrateSQLData/
├── Public/
│   └── Migrate-SQLData.ps1
├── Private/
│   ├── Get-SqlConnection.ps1
│   ├── Get-SQLData.ps1
│   └── Invoke-DataTransformation.ps1
│   └── Write-SQLData.ps1
├── Tests/
│   └── MigrateSQLData.Tests.ps1
├── Transforms/
│   └── ToUpperTransform.ps1  # Example transformation
└── build.ps1
```


*   `Public`: Contains the main `Migrate-SQLData` function.
*   `Private`: Holds internal helper functions.
*   `Tests`: Contains Pester unit tests.
*   `Transforms`: Holds transformation scripts.
*   `build.ps1`: The build script for testing, deploying, and migrating.

## Prerequisites

*   PowerShell 5.1 or later
*   SQL Server Management Studio (SSMS) or access to the SQL Server databases
*   Pester testing framework (install using `Install-Module Pester`)

## Installation

1.  Clone this repository or download the files.
2.  Place the `MigrateSQLData` folder in your PowerShell module path. You can find your module paths by running `$env:PSModulePath`.

## Usage

### 1. Configuration

*   Create a configuration file (`.psd1`) in the `Config` folder (create the folder if it doesn't exist).
*   Specify the source and destination server details, authentication settings, transformation name, and other options in the configuration file. See `Config/migration_instance1.psd1` for an example.

### 2. Running the Migration

*   Open PowerShell and navigate to the `MigrateSQLData` directory.
*   Run the `build.ps1` script with the `-ConfigFile` parameter:

```powershell
.\build.ps1 -ConfigFile ".\Config\migration_instance1.psd1"
```

* This will:
    * Run the unit tests.
    * Deploy the module and transformation scripts to C:\Target\Directory.
    * Execute the data migration using the settings in the configuration file.

### 3. Other Tasks

* To run only the tests:
```powershell
.\build.ps1 -Task Test
```


## Transformations

  * Create transformation scripts (`.ps1` files) in the `Transforms` folder.
  * Each script should contain a function that accepts a `DataTable` as input and returns the modified `DataTable`.
  * Specify the `TransformName` parameter in the configuration file to apply a transformation during migration.

## Logging

  * The `Migrate-SQLData` function handles logging.
  * Log files are created with the pattern `MigrateSQLData_yyyyMMdd.log`.

## Contributing

Feel free to contribute to this project by submitting issues or pull requests.

## License

This project is released to the public domain using the Unlicense. See [LICENSE](LICENSE) file for details.
