
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$mdFile
)

$mdData = Get-Content -Path $mdFile

$outputData = @()
foreach ($line in $mdData) {
    if ($line -like "- Line #*") {
        $linePrefix = $line.Split("|")[0]
        $lineNumber = $linePrefix.Split("#")[1]
        $arrayLineNumber = $lineNumber - 1

        $filePath = $line.Split("|")[1]
        if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
            $filePath = $filePath.Replace("/","\")
        }
        Write-ActionInfo "Looking for files in $env:GITHUB_WORKSPACE"
        
        $workspaceFiles = Get-ChildItem -Path "$env:GITHUB_WORKSPACE" -Recurse -File
        Write-ActionInfo "Found $($workspaceFiles.Count) files"
        $resolvedFilePath = $workspaceFiles | Where-Object {$_.FullName -like "*$filePath"}
        if (Test-Path $resolvedFilePath) {
            $fileContents = Get-Content -Path $resolvedFilePath
            $missedLine = $fileContents[$arrayLineNumber]

            $outputData += $linePrefix
            $outputData += "``````"
                $outputData += $missedLine
            $outputData += "``````"
        } else {
            Write-ActionInfo "Could not find $filePath in $env:GITHUB_WORKSPACE"
    }
    else {
        $outputData += $line
    }
}

Set-Content -Value $outputData -Path $mdFile
