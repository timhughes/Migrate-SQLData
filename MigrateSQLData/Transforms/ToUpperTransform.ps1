# Transforms/ToUpperTransform.ps1
function ToUpper-Column {
    param(
        [Parameter(Mandatory = $true)]
        [System.Data.DataTable]$DataTable,
        [Parameter(Mandatory = $true)]
        [string]$ColumnName
    )

    foreach ($row in $DataTable.Rows) {
        $row[$ColumnName] = $row[$ColumnName].ToUpper()
    }

    return $DataTable
}
