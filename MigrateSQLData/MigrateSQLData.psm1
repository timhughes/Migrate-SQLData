#requires -Version 2
#Get public and private function definition files.
$Public = @( Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )
$Scripts = @( Get-ChildItem -Path "$PSScriptRoot/Scripts" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private + $Scripts)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
