$ProjectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$reportDir = Join-Path $ProjectRoot "Starbucks_PowerBI.Report"
$pagesDir = Join-Path $reportDir "definition\pages"
$pageFolder = Get-ChildItem -Path $pagesDir -Directory | Select-Object -First 1
if (-not $pageFolder) {
    Write-Error "No page folder found in the report."
    exit
}

$visualsDir = Join-Path $pageFolder.FullName "visuals"
if (Test-Path $visualsDir) {
    Write-Host "Cleaning up existing visuals..."
    Remove-Item -Path "$visualsDir\*" -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $visualsDir | Out-Null
}
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
Create-VisualJson -VisualName "vis_channel_summary" -VisualType "columnChart" -X 10 -Y 10 -Width 600 -Height 180 -TitleText "Channel Performance During Morning Rush"

Create-VisualJson -VisualName "vis_complexity_impact" -VisualType "barChart" -X 630 -Y 10 -Width 600 -Height 180 -TitleText "Complexity vs Delay Correlation"

Create-VisualJson -VisualName "vis_geo_differences" -VisualType "scatterChart" -X 10 -Y 210 -Width 600 -Height 200 -TitleText "Geographic Differences & Satisfaction"

# Visual 4: Weekly Patterns
Create-VisualJson -VisualName "vis_weekly_trend" -VisualType "lineChart" -X 630 -Y 210 -Width 600 -Height 200 -TitleText "Weekly Fulfillment Patterns"

Write-Host "Successfully generated all report visuals in PBIR format!"
Write-Host "You can now open Starbucks_PowerBI.pbip in Power BI Desktop to see the generated visuals on the canvas."
