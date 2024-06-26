# Azure DevOps Yaml Validation and Merge Tool

## Description

Powershell scripts to merge Azure DevOps pipelines and their templates into a single pipeline YAML. Combined file can be validated with the Azure DevOps API Preview endpoint to validate pipeline. 

## Installation

Clone this repo or directly download the `Az.DevOps.YamlParse.ps1` and `Az.DevOps.PipelinePreview.ps1` scripts.

## Usage

NOTE: These examples are for WSL, but with minor path changes should work in Windows PS.

Prep Steps:
Determine the account name, project name and pipeline ID from the ADO pipeline url. You must create an initial version of the pipeline in ADO in order to reference its pipeline ID. Ensure the PAT has at least Build Run & Execute permissions.

`https://dev.azure.com/<account_name>/<project_name>/_build?definitionId=<pipeline_id>`

Example Command

```
./my_script_dir/Az.DevOps.PipelinePreview.ps1 -AzureDevOpsPAT "********" `
 -OrganizationName "<account_name>" `
 -ProjectName "<project_name>" `
 -PipelineId "<pipeline_id>" `
 -PipelineFile ./pipeline.yml `
 -TemplateParameters @{ "foo" = "bar" } `
 -MergePipelineYaml `
 -SaveMergedPipeline
```

This should create a fully merged pipeline named `full-pipeline.yml` in the same directory as `pipeline.yml`. The script will then attempt to pass the merged Yaml to the Azure DevOps Preview API to validate it.

If it is successful, you should see `Pipeline Preview Successful`. If there is an issue with the pipeline, you will get an error and some context indicating where the error is in your merged Yaml content.

Here's an example of an error

```
                                                                                                                        
/pipelines/pipeline.yml (Line: 26, Column: 10): Unexpected value ''

Context:
        24     displayName: "My display name"
        25 
     => 26     jobs:
                    ^
        27     jobs:
        28     - job: My_Job_Name
        29       displayName: 'My Job Name'
        30       steps:
        31         # dependency-install-steps.yml
        32         - script: |

/pipelines/snowflake-customer-deployment.yml (Line: 27, Column: 5): 'jobs' is already defined

Context:
        24     displayName: "My display name"
        25 
        26     jobs:
     => 27     jobs:
               ^
        28     - job: My_Job_Name
        29       displayName: 'My Job Name'
        30       steps:
        31         # dependency-install-steps.yml
        32         - script: |

Write-Error: 
Microsoft.Azure.Pipelines.WebApi.PipelineValidationException, Microsoft.Azure.Pipelines.WebApi
PipelineValidationException
```