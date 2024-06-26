# Process script parameters
# Example: ./Az.DevOps.Preview.ps1 -AzureDevOpsPAT "*****" `
#            -OrganizationName "my_org" -ProjectName "my_proj" -PipelineId "42" `
#            -PipelineFile "pipeline.yml" -templateParameters @{"foo"="bar"; "baz"="qux"}
param(
    [string]$AzureDevOpsPAT,
    [string]$OrganizationName,
    [string]$ProjectName,
    [string]$PipelineId,
    [string]$PipelineFile,
    [hashtable]$TemplateParameters
    #    [string]$RepoBranch
)

# Function to format the error message from the pipeline preview
# Color highlights the error message, and prints the context of the error in the YAML file
function Format-Preview-Error {
    param (
        [string]$PipelineFile,
        [string]$ErrorMessage
    )

    foreach ( $errorLine in ($ErrorMessage -split "\r?\n|\r") ) {
        # Regular expression to capture file path, line and column, and error message
        $pattern = "^(.+?) \(Line: (\d+), Col: (\d+)\): (.+)$"

        # Use -match operator to apply the regex pattern and capture groups
        if ($errorLine -match $pattern) {
            $filePath = $matches[1]
            $line = [int]$matches[2]
            $column = [int]$matches[3]
            $errorDescription = $matches[4]

            # Try colors
            Write-Host "`n$filePath " -ForegroundColor White -NoNewline; 
            Write-Host "(Line: $line, Column: $column): " -ForegroundColor Blue -NoNewline; 
            Write-Host $errorDescription -ForegroundColor Red;

            # Enable underline
            $esc = [char]27
            Write-Host "`n$esc[4mContext:$esc[0m" -ForegroundColor White

            # Print context
            if ($line -gt 5) {
                $startLine = $line - 5
            }
            else {
                $startLine = 0
            }
            $endLine = $line + 5
            foreach ($fileLine in (Get-Content -Path $PipelineFile)[($startLine)..($endLine)]) {
                if ($fileLine.ReadCount -eq $line) {
                    # Highlight line
                    Write-Host ("{0,10} {1}" -f ("=> " + $fileLine.ReadCount), $fileLine) -ForegroundColor Blue
                    # Highlight column
                    Write-Host (" " * ($column + 10) + "^") -ForegroundColor Green
                }
                else { 
                    Write-Host ("{0,10} {1}" -f $fileLine.ReadCount, $fileLine)
                }
            }
        }
 
        else {
            Write-Host "The error message does not match the expected format."
            Write-Host $errorLine
        }
    }
}

# Build auth header from PAT
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

# Build the URI for the pipeline preview
$APIVersion = "7.2-preview.1"
$URI = "https://dev.azure.com/$($OrganizationName)/" 
$URI = $URI + "$($ProjectName)/_apis/pipelines/$($PipelineId)/preview?api-version=$($APIVersion)"

# Read in the YAML file
$pipelineYaml = Get-Content -Path $PipelineFile -Raw

# Example of a complete pipeline preview body
#$pipelinePreviewBody = @{
#    "resources"        = @{
#        "pipelines"    = @{}
#        "repositories" = @{
#            "self" = @{
#                "refName" = "azure-pipelines"
#            }
#        }
#        "builds"       = @{}
#        "containers"   = @{}
#        "packages"     = @{}
#    }
#    templateParameters = @{}
#    "previewRun"       = $true
#    "yamlOverride"     = $pipelineYaml
#}  | ConvertTo-Json -Depth 5

$pipelinePreviewBody = @{
    "templateParameters" = $TemplateParameters
    "previewRun"         = $true
    "yamlOverride"       = $pipelineYaml
}  | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri $URI -Method Post -Headers $AzureDevOpsAuthenicationHeader -Body $pipelinePreviewBody -ContentType "application/json"
}
catch {
    # Check to see if the rest API call returned an error
    if ($_.ErrorDetails.Message) {
        $errorMessage = ($_.ErrorDetails.Message | ConvertFrom-Json).message
        Format-Preview-Error -PipelineFile $PipelineFile -ErrorMessage $errorMessage

        # Print type and key of the error from the API
        $formattedError = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Error ("`n" + $formattedError.typeName + "`n" + $formattedError.typeKey) -ErrorAction Stop

    } else {
        # We encountered an exception with the original Rest API call
        # rethrow the exception
        throw
    }
}

Write-Host "Pipeline Preview Successful:"
Write-Host $response