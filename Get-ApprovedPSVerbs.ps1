<#
.SYNOPSIS
Webcrawl for MS approved-verbs-for-windows-powershell-commands
.NOTES
In any normal use-case you want to use PS>Get-Verb instead
#>
param(
	[Parameter(Mandatory = $true)][string]$psversion,
	[Parameter(Mandatory = $true)][string]$url
)

# Output file
$outputFile = ".\ApprovedVerbs-v$($psversion).json"

# Microsoft documentation URL
#$url = "https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-5.1"

Write-Host "Downloading approved verbs page..."

$html = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content

$rows = [regex]::Matches(
    $html,
    '<tr[^>]*>(.*?)</tr>',
    [Text.RegularExpressions.RegexOptions]::Singleline
)

$verbs = foreach ($row in $rows) {

    $cells = [regex]::Matches(
        $row.Value,
        '<td[^>]*>(.*?)</td>',
        [Text.RegularExpressions.RegexOptions]::Singleline
    )

    if ($cells.Count -ne 3) {
        continue
    }

    #
    # First column contains:
    # <a><code>Revoke</code></a> (<code>rk</code>)
    #
    $verbMatch = [regex]::Match(
        $cells[0].Groups[1].Value,
        '<code>([^<]+)</code>'
    )

    if (-not $verbMatch.Success) {
        continue
    }

    $verb = $verbMatch.Groups[1].Value.Trim()

    #
    # Third column contains:
    # <code>Remove</code>, <code>Disable</code>
    #
    $synonyms = [regex]::Matches(
        $cells[2].Groups[1].Value,
        '<code>([^<]+)</code>'
    ) | ForEach-Object {
        $_.Groups[1].Value.Trim()
    }

    [PSCustomObject]@{
        Verb             = $verb
        SynonymsToAvoid  = @($synonyms)
    }
}

$verbs |
    Sort-Object Verb |
    ConvertTo-Json -Depth 3 -Compress |
    Set-Content $outputFile -Encoding UTF8

Write-Host "Exported $($verbs.Count) approved verbs"