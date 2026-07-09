function Convert-JiraCsv {
    param(
        [Parameter(Mandatory)]
        [string]$InputFile,

        [Parameter(Mandatory)]
        [string]$OutputFile,

        [string]$Projekt = "Projekt A",
        [string]$Farbe = "SteelBlue"
    )

    $csv = Import-Csv -Path $InputFile -Delimiter ';'

    $result = foreach ($row in $csv) {

        # Datumsformat vereinheitlichen
        $start = if ($row.'Erstellt') {
            (Get-Date $row.'Erstellt').ToString('yyyy-MM-dd')
        } else {
            ""
        }

        $ende = if ($row.'Fälligkeitsdatum') {
            (Get-Date $row.'Fälligkeitsdatum').ToString('yyyy-MM-dd')
        } else {
            ""
        }

        [PSCustomObject]@{
            Projekt = $Projekt
            Farbe    = $Farbe
            Aufgabe  = $row.'Zusammenfassung'
            Jira     = $row.'Vorgangsschlüssel'
            Start    = $start
            Ende     = $ende
        }
    }

    $result | Export-Csv -Path $OutputFile -Delimiter ';' -NoTypeInformation -Encoding UTF8
}