# Script: Create_Report_Visuals.ps1
# Purpose: Programmatically generate visual components for the Starbucks Power BI report
# using the PBIR (Power BI Enhanced Report Format) specification.

# Determine the directory where this script resides, then go one level up to the project root
$ProjectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$reportDir = Join-Path $ProjectRoot "Starbucks_PowerBI.Report"
$pagesDir = Join-Path $reportDir "definition\pages"

# Find the first page (or specify "17100a3adf3ef7df355a")
$pageFolder = Get-ChildItem -Path $pagesDir -Directory | Select-Object -First 1
if (-not $pageFolder) {
    Write-Error "No page folder found in the report."
    exit
}

$visualsDir = Join-Path $pageFolder.FullName "visuals"

# Ensure visuals directory exists
if (Test-Path $visualsDir) {
    Write-Host "Cleaning up existing visuals..."
    Remove-Item -Path "$visualsDir\*" -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $visualsDir | Out-Null
}

# Function to generate a basic visual struct
function Create-VisualJson {
    param (
        [string]$VisualName,
        [string]$VisualType,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [string]$TitleText
    )

    $schema = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/1.2.0/schema.json"

    # Creating a hashtable structure that converts cleanly to JSON
    $visualObj = @{
        "`$schema" = $schema
        name = $VisualName
        position = @{
            x = $X
            y = $Y
            z = 1
            width = $Width
            height = $Height
        }
        visual = @{
            visualType = $VisualType
            visualContainerObjects = @{
                title = @(
                    @{
                        properties = @{
                            text = @{
                                expr = @{
                                    Literal = @{
                                        Value = "'$TitleText'"
                                    }
                                }
                            }
                            show = @{
                                expr = @{
                                    Literal = @{
                                        Value = "true"
                                    }
                                }
                            }
                        }
                    }
                )
            }
        }
    }

    $json = $visualObj | ConvertTo-Json -Depth 10
    
    $targetFolder = Join-Path $visualsDir $VisualName
    New-Item -ItemType Directory -Path $targetFolder | Out-Null
    
    $targetFile = Join-Path $targetFolder "visual.json"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($targetFile, $json, $utf8NoBom)
    
    Write-Host "Created visual '$TitleText' of type '$VisualType' at $targetFile"
}

Write-Host "Generating programmatic visuals for Starbucks Operations Dashboard..."

# Visual 1: Channel Comparison (Drive-Thru vs Mobile)
Create-VisualJson -VisualName "vis_channel_compare" -VisualType "columnChart" -X 10 -Y 10 -Width 600 -Height 330 -TitleText "Fulfillment Time: Drive-Thru vs Mobile (Morning Rush)"

# Visual 2: Complexity Impact (Bar Chart)
Create-VisualJson -VisualName "vis_complexity_bar" -VisualType "barChart" -X 630 -Y 10 -Width 600 -Height 330 -TitleText "Average Delays by Cart Size"

# Visual 3: Weekly Patterns
Create-VisualJson -VisualName "vis_weekly_trend" -VisualType "lineChart" -X 10 -Y 360 -Width 600 -Height 330 -TitleText "Weekly Patterns: Critical Days for Staff Planning"

Write-Host "Successfully generated all report visuals in PBIR format!"
Write-Host "You can now open Starbucks_PowerBI.pbip in Power BI Desktop to see the generated visuals on the canvas."
