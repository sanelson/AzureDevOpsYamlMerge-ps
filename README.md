# Azure DevOps Yaml Merge Tool

## Description

Powershell script to merge Azure DevOps pipelines and their templates into a single pipeline YAML. Combined file can be used with the Azure DevOps API Preview endpoint to validate pipeline. See VSTeam Integration below.

## Installation

Clone this repo or directly download the `Az.DevOps.YamlParse.ps1` script.

## Usage

NOTE: These examples are for WSL, but with minor path changes should work in Windows PS.

Source the script

```
. ./Az.DevOps.YamlParse.ps1
```

Assuming a root of the current directory which also contains the main pipeline `pipeline.yml'. Template paths within the pipeline should either be absolute or relative to this rootpath.

```
$outputPath = processMainPipeline -pipelineYaml pipeline.yml -rootPath $PWD.Path
```

This should create a fully merged pipeline named `full-pipeline.yml` in the rootpath.

## VSTeam Integration

link: https://github.com/MethodsAndPractices/vsteam

Determine the account name, project name and pipeline ID from the ADO pipeline url.

https://dev.azure.com/<account_name>/<project_name>/_build?definitionId=<pipeline_id>

Note: You must create an initial version of the pipeline in ADO in order to reference its pipeline ID. Also, note the branch name in which the pipeline was created. 

Install VSTeam Module

```
Install-Module -Name VSTeam -Repository PSGallery -Scope CurrentUser
```

Configure account access. Ensure the PAT has at least Build Run & Execute permissions.

```
Set-VSTeamAccount -Account <account_name> -PersonalAccessToken *****
```

Now validate the pipeline. In this example we use the `full-pipeline.yml' created by the YAML merge script previously.

```
Test-VSTeamYamlPipeline -Project <project_name> -PipelineId <pipeline_id> -FilePath full-pipeline.yml -Branch <branch_name>
```