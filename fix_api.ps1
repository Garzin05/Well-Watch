$file = "C:\Users\Pudinga\Documents\Well-Watch\Código-Well-Watch\lib\services\api_service.dart"
$content = Get-Content $file -Raw
# Remove the trailing backticks and any whitespace after the final }
$content = $content -replace '}\s*```\s*`{4}\s*$', '}'
Set-Content $file -Value $content -Encoding UTF8
Write-Host "Fixed api_service.dart"
