<#
.SYNOPSIS
Given a path, checks wether the .ps1 files conform to the Verb-Noun.ps1 format
.NOTES
In any normal use-case you want to use the PSScriptAnalyzer-Module instead
Version: 1.0.0
.EXAMPLE
"A:\path" | .\Confirm-ApprovedVerbsUsed.ps1
"A:\path\*.ps1" | .\Confirm-ApprovedVerbsUsed.ps1
gci .\ -filter *.ps1 | .\Confirm-ApprovedVerbsUsed.ps1
gci .\..\ -Recurse -Filter *.ps1 | .\Confirm-ApprovedVerbsUsed.ps1
"A:\path", "Change-test.ps1" | .\Confirm-ApprovedVerbsUsed.ps1
.\Confirm-ApprovedVerbsUsed.ps1 -path "A:\path", "Change-test.ps1"
.\Confirm-ApprovedVerbsUsed.ps1 -path "A:\path"
.\Confirm-ApprovedVerbsUsed.ps1 -path "A:\path\*.ps1" 
#>
[CmdletBinding()]
param(
    [Parameter(
        Position = 0,
        Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName
    )]
    [Alias('FullName')]
    [string[]]$Path
)

begin{
	$approvedVerbs = '[{"Verb":"Add","SynonymsToAvoid":["Append","Attach","Concatenate","Insert"]},{"Verb":"Approve","SynonymsToAvoid":[]},{"Verb":"Assert","SynonymsToAvoid":["Certify"]},{"Verb":"Backup","SynonymsToAvoid":["Save","Burn","Replicate","Sync"]},{"Verb":"Block","SynonymsToAvoid":["Prevent","Limit","Deny"]},{"Verb":"Build","SynonymsToAvoid":[]},{"Verb":"Checkpoint","SynonymsToAvoid":["Diff"]},{"Verb":"Clear","SynonymsToAvoid":["Flush","Erase","Release","Unmark","Unset","Nullify"]},{"Verb":"Close","SynonymsToAvoid":[]},{"Verb":"Compare","SynonymsToAvoid":["Diff"]},{"Verb":"Complete","SynonymsToAvoid":[]},{"Verb":"Compress","SynonymsToAvoid":["Compact"]},{"Verb":"Confirm","SynonymsToAvoid":["Acknowledge","Agree","Certify","Validate","Verify"]},{"Verb":"Connect","SynonymsToAvoid":["Join","Telnet","Login"]},{"Verb":"Convert","SynonymsToAvoid":["Change","Resize","Resample"]},{"Verb":"ConvertFrom","SynonymsToAvoid":["Export","Output","Out"]},{"Verb":"ConvertTo","SynonymsToAvoid":["Import","Input","In"]},{"Verb":"Copy","SynonymsToAvoid":["Duplicate","Clone","Replicate","Sync"]},{"Verb":"Debug","SynonymsToAvoid":["Diagnose"]},{"Verb":"Deny","SynonymsToAvoid":["Block","Object","Refuse","Reject"]},{"Verb":"Deploy","SynonymsToAvoid":[]},{"Verb":"Disable","SynonymsToAvoid":["Halt","Hide"]},{"Verb":"Disconnect","SynonymsToAvoid":["Break","Logoff"]},{"Verb":"Dismount","SynonymsToAvoid":["Unmount","Unlink"]},{"Verb":"Edit","SynonymsToAvoid":["Change","Update","Modify"]},{"Verb":"Enable","SynonymsToAvoid":["Start","Begin"]},{"Verb":"Enter","SynonymsToAvoid":["Push","Into"]},{"Verb":"Exit","SynonymsToAvoid":["Pop","Out"]},{"Verb":"Expand","SynonymsToAvoid":["Explode","Uncompress"]},{"Verb":"Export","SynonymsToAvoid":["Extract","Backup"]},{"Verb":"Find","SynonymsToAvoid":["Search"]},{"Verb":"Format","SynonymsToAvoid":[]},{"Verb":"Get","SynonymsToAvoid":["Read","Open","Cat","Type","Dir","Obtain","Dump","Acquire","Examine","Find","Search"]},{"Verb":"Grant","SynonymsToAvoid":["Allow","Enable"]},{"Verb":"Group","SynonymsToAvoid":[]},{"Verb":"Hide","SynonymsToAvoid":["Block"]},{"Verb":"Import","SynonymsToAvoid":["BulkLoad","Load"]},{"Verb":"Initialize","SynonymsToAvoid":["Erase","Init","Renew","Rebuild","Reinitialize","Setup"]},{"Verb":"Install","SynonymsToAvoid":["Setup"]},{"Verb":"Invoke","SynonymsToAvoid":["Run","Start"]},{"Verb":"Join","SynonymsToAvoid":["Combine","Unite","Connect","Associate"]},{"Verb":"Limit","SynonymsToAvoid":["Quota"]},{"Verb":"Lock","SynonymsToAvoid":["Restrict","Secure"]},{"Verb":"Measure","SynonymsToAvoid":["Calculate","Determine","Analyze"]},{"Verb":"Merge","SynonymsToAvoid":["Combine","Join"]},{"Verb":"Mount","SynonymsToAvoid":["Connect"]},{"Verb":"Move","SynonymsToAvoid":["Transfer","Name","Migrate"]},{"Verb":"New","SynonymsToAvoid":["Create","Generate","Build","Make","Allocate"]},{"Verb":"Open","SynonymsToAvoid":[]},{"Verb":"Optimize","SynonymsToAvoid":[]},{"Verb":"Out","SynonymsToAvoid":[]},{"Verb":"Ping","SynonymsToAvoid":[]},{"Verb":"Pop","SynonymsToAvoid":[]},{"Verb":"Protect","SynonymsToAvoid":["Encrypt","Safeguard","Seal"]},{"Verb":"Publish","SynonymsToAvoid":["Deploy","Release","Install"]},{"Verb":"Push","SynonymsToAvoid":[]},{"Verb":"Read","SynonymsToAvoid":["Acquire","Prompt","Get"]},{"Verb":"Receive","SynonymsToAvoid":["Read","Accept","Peek"]},{"Verb":"Redo","SynonymsToAvoid":[]},{"Verb":"Register","SynonymsToAvoid":[]},{"Verb":"Remove","SynonymsToAvoid":["Clear","Cut","Dispose","Discard","Erase"]},{"Verb":"Rename","SynonymsToAvoid":["Change"]},{"Verb":"Repair","SynonymsToAvoid":["Fix","Restore"]},{"Verb":"Request","SynonymsToAvoid":[]},{"Verb":"Reset","SynonymsToAvoid":[]},{"Verb":"Resize","SynonymsToAvoid":[]},{"Verb":"Resolve","SynonymsToAvoid":["Expand","Determine"]},{"Verb":"Restart","SynonymsToAvoid":["Recycle"]},{"Verb":"Restore","SynonymsToAvoid":["Repair","Return","Undo","Fix"]},{"Verb":"Resume","SynonymsToAvoid":[]},{"Verb":"Revoke","SynonymsToAvoid":["Remove","Disable"]},{"Verb":"Save","SynonymsToAvoid":[]},{"Verb":"Search","SynonymsToAvoid":["Find","Locate"]},{"Verb":"Select","SynonymsToAvoid":["Find","Locate"]},{"Verb":"Send","SynonymsToAvoid":["Put","Broadcast","Mail","Fax"]},{"Verb":"Set","SynonymsToAvoid":["Write","Reset","Assign","Configure","Update"]},{"Verb":"Show","SynonymsToAvoid":["Display","Produce"]},{"Verb":"Skip","SynonymsToAvoid":["Bypass","Jump"]},{"Verb":"Split","SynonymsToAvoid":["Separate"]},{"Verb":"Start","SynonymsToAvoid":["Launch","Initiate","Boot"]},{"Verb":"Step","SynonymsToAvoid":[]},{"Verb":"Stop","SynonymsToAvoid":["End","Kill","Terminate","Cancel"]},{"Verb":"Submit","SynonymsToAvoid":["Post"]},{"Verb":"Suspend","SynonymsToAvoid":["Pause"]},{"Verb":"Switch","SynonymsToAvoid":[]},{"Verb":"Sync","SynonymsToAvoid":["Replicate","Coerce","Match"]},{"Verb":"Test","SynonymsToAvoid":["Diagnose","Analyze","Salvage","Verify"]},{"Verb":"Trace","SynonymsToAvoid":["Track","Follow","Inspect","Dig"]},{"Verb":"Unblock","SynonymsToAvoid":["Clear","Allow"]},{"Verb":"Undo","SynonymsToAvoid":[]},{"Verb":"Uninstall","SynonymsToAvoid":[]},{"Verb":"Unlock","SynonymsToAvoid":["Release","Unrestrict","Unsecure"]},{"Verb":"Unprotect","SynonymsToAvoid":["Decrypt","Unseal"]},{"Verb":"Unpublish","SynonymsToAvoid":["Uninstall","Revert","Hide"]},{"Verb":"Unregister","SynonymsToAvoid":["Remove"]},{"Verb":"Update","SynonymsToAvoid":["Refresh","Renew","Recalculate","Re-index"]},{"Verb":"Use","SynonymsToAvoid":[]},{"Verb":"Wait","SynonymsToAvoid":["Sleep","Pause"]},{"Verb":"Watch","SynonymsToAvoid":[]},{"Verb":"Write","SynonymsToAvoid":["Put","Print"]}]'
	$Mappings = $approvedVerbs | ConvertFrom-Json
	
	$ApprovedVerbSet = [System.Collections.Generic.HashSet[string]]::new(
		[System.StringComparer]::OrdinalIgnoreCase
	)
	Get-Verb | ForEach-Object {
		$null = $ApprovedVerbSet.Add($_.Verb)
	}

	$ReverseLookup = @{}
	foreach ($Entry in $Mappings) {
		foreach ($Synonym in $Entry.SynonymsToAvoid) {

			# Ignore synonyms that are themselves approved verbs
			if ($ApprovedVerbSet.Contains($Synonym)) {
				continue
			}

			if (-not $ReverseLookup.ContainsKey($Synonym)) {
				$ReverseLookup[$Synonym] = [System.Collections.Generic.List[string]]::new()
			}

			$ReverseLookup[$Synonym].Add($Entry.Verb)
		}
	}
	
	$TestScriptVerb = {
		param(
			[System.IO.FileInfo]$File,
			[hashtable]$ReverseLookup
		)
		if ($File.Name -match '^([A-Za-z]+)-(.+)\.ps1$') {
			$verb = $Matches[1]

			if ($ReverseLookup.ContainsKey($verb)) {
				[PSCustomObject]@{
					File           = $File.FullName
					UnapprovedVerb = $verb
					SuggestedVerb  = $ReverseLookup[$verb] -join ', '
				}
			}
		}
	}
}

process {
    foreach ($p in $Path) {
		try {
			$resolvedPaths = Resolve-Path -Path $p -ErrorAction Stop
		}
		catch {
			Write-Host "$p couldn't be resolved" -ForegroundColor Red
			continue
		}
		foreach ($resolved in $resolvedPaths) {
			$item = Get-Item -LiteralPath $resolved
			if ($item.PSIsContainer) {
				$files = Get-ChildItem -LiteralPath $item.FullName -Recurse -Filter *.ps1 -File 
				foreach ($file in $files) {
					& $TestScriptVerb -File $file -ReverseLookup $ReverseLookup
				}
			}
			else {
				& $TestScriptVerb -File $item -ReverseLookup $ReverseLookup
			}
        }
    }
}
