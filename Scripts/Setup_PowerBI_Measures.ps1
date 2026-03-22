# ============================================================
# SCRIPT: Setup_PowerBI_Measures.ps1
# Purpose: Programmatically injects DAX measures into the TMDL
# ============================================================

$file = "c:\Users\Pc\Downloads\Starbucks_PowerBI.SemanticModel\definition\tables\FactOrders.tmdl"
$content = Get-Content $file -Raw

$measures = @"

	measure 'Avg Fulfillment Time' = AVERAGE(FactOrders[fulfillment_time_min])
		formatString: 0.00
		lineageTag: $([Guid]::NewGuid())

	measure 'Avg Satisfaction' = AVERAGE(FactOrders[customer_satisfaction])
		formatString: 0.0
		lineageTag: $([Guid]::NewGuid())

	measure 'Complexity Correlation' = 
		VAR CorrelationValue = 
			VAR MeanX = AVERAGE(FactOrders[num_customizations])
			VAR MeanY = AVERAGE(FactOrders[fulfillment_time_min])
			RETURN 
				DIVIDE(
					SUMX(FactOrders, (FactOrders[num_customizations] - MeanX) * (FactOrders[fulfillment_time_min] - MeanY)),
					SQRT(
						SUMX(FactOrders, (FactOrders[num_customizations] - MeanX) ^ 2) * 
						SUMX(FactOrders, (FactOrders[fulfillment_time_min] - MeanY) ^ 2)
					)
				)
		RETURN CorrelationValue
		formatString: 0.00
		lineageTag: $([Guid]::NewGuid())
"@

if ($content -notlike "*'Avg Fulfillment Time'*") {
    $newContent = $content.Replace("partition FactOrders = m", "$measures`n`n	partition FactOrders = m")
    Set-Content $file $newContent
    Write-Host "✅ Measures injected successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Measures already exist." -ForegroundColor Yellow
}
