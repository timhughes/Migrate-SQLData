# Private/Invoke-DataTransformation.ps1

<#
.SYNOPSIS
    Applies a specified data transformation to a DataTable.

.DESCRIPTION
    This function loads transformation functions from external PowerShell scripts
    in the "Transforms" folder and applies the specified transformation to the
    input DataTable.

.PARAMETER DataTable
    The DataTable to be transformed.

.PARAMETER TransformName
    The name of the transformation function to apply.
    If not specified, no transformation is applied.

.RETURNS
    The transformed DataTable.

.EXAMPLE
    Invoke-DataTransformation -DataTable $data -TransformName "ToUpperTransform"

    This example applies the "ToUpperTransform" transformation to the $data DataTable.

.NOTES
    The transformation functions should be defined in separate .ps1 files
    in the "Transforms" folder. Each function should accept a DataTable as input
    and return the modified DataTable.
#>
function Invoke-DataTransformation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Data.DataTable]$DataTable,

        [Parameter(Mandatory = false)]
        [string]$TransformName = "None"
    )

    # Load transformations from external ps1 files in the Transforms folder
    $TransformPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path)  "..\Transforms"
    Get-ChildItem -Path $TransformPath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName  # Dot-source each script to load the functions
    }

    # Get the specified transformation function
    $transformFunction = Get-Command -Name $TransformName -ErrorAction SilentlyContinue
    if ($transformFunction) {
        return & $transformFunction $DataTable  # Invoke the function with the DataTable
    }
    else {
        Write-Warning "Transformation '$TransformName' not found. No transformation will be applied."
        return $DataTable  # Return the original DataTable if no transformation is found
    }
}
