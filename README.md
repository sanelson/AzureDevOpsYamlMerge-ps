# Azure DevOps Yaml Merge Tool

## Description

Powershell script to merge Azure DevOps pipelines and their templates into a single pipeline YAML. Combined file can be used with the Azure DevOps API Preview endpoint to validate pipeline.

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