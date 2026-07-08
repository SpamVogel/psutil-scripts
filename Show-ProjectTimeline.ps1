Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

$csvFile = ".\ProjectTimeline.csv"
$jiraBaseUrl = "https://company.atlassian.net/browse/"

$form = New-Object Windows.Forms.Form
$form.Text = "Project Roadmap"
$form.Width = 1920
$form.Height = 1080

# Loading csv
if (!(Test-Path $csvFile)) {
    [System.Windows.Forms.MessageBox]::Show("CSV not found:`n$csvFile")
    exit
}
$data = Import-Csv $csvFile -Delimiter ";"

# Project-Tasklist
$taskY = @{}
$counter = 1
$currentProject = ""

foreach($row in $data | Sort-Object Project, Start){
    if($currentProject -ne $row.Project){
        $counter += 1 # greater spacing between different projects
        $currentProject = $row.Project
    }
    $key = "$($row.Project) - $($row.ProjectTask)"
    $taskY[$key] = $counter
    $counter += 0.35 # smaller spacing between project-task
}

# Extract project-colors from csv
$projectColor=@{}
foreach($row in $data){
    if(!$projectColor.ContainsKey($row.Project)){
        $projectColor[$row.Project]=$row.Colour
    }
}

# Determine date-range
$dates=@()
foreach($row in $data){
    $dates += Get-Date $row.Start
    $dates += Get-Date $row.End
}
$minDate = ($dates | Measure-Object -Minimum).Minimum
$maxDate = ($dates | Measure-Object -Maximum).Maximum
$chartStart = Get-Date ($minDate.ToString("yyyy-MM-01"))
$chartEnd = $maxDate.AddMonths(1)

# Create Chart
$chart = New-Object Windows.Forms.DataVisualization.Charting.Chart
$chart.Dock = "Fill"
$area = New-Object Windows.Forms.DataVisualization.Charting.ChartArea

# X-Achse
$area.AxisX.Title = "Time"
$area.AxisX.LabelStyle.Format = "MMM yyyy"
$area.AxisX.Interval = 1
$area.AxisX.IntervalType = [System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType]::Months

# Y-Achse
$area.AxisY.Minimum = 0
$area.AxisY.Maximum = $data.Count+1
$area.AxisY.Interval = 1
$area.AxisY.IsReversed = $true

foreach($row in $data){
    $label = New-Object System.Windows.Forms.DataVisualization.Charting.CustomLabel
    $key = "$($row.Project) - $($row.ProjectTask)"
    $pos = $taskY[$key]
    $label.FromPosition = $pos-0.5
    $label.ToPosition = $pos+0.5
    $label.Text = "$($row.Project) - $($row.ProjectTask)"
    $area.AxisY.CustomLabels.Add($label)
}

# Monthly grid
$current = $chartStart
while($current -lt $chartEnd){
    $monthLine = New-Object System.Windows.Forms.DataVisualization.Charting.StripLine
    $monthLine.IntervalOffset = $current.ToOADate()
    $monthLine.BorderColor = "LightGray"
    $monthLine.BorderWidth = 1
    $monthLine.BorderDashStyle = "Dash"
    $area.AxisX.StripLines.Add($monthLine)
    $current = $current.AddMonths(1)
}
$chart.ChartAreas.Add($area)

# Draw Tasks
foreach($task in $data){
    $key = "$($task.Project) - $($task.ProjectTask)"
    $y = $taskY[$key]
    # Line per task
    $line = New-Object Windows.Forms.DataVisualization.Charting.Series
    $line.Name = "$($task.Project) - $($task.ProjectTask)"
    $line.ChartType = "Line"
    $line.BorderWidth = 3
    $line.Color = $projectColor[$task.Project]
    $line.Points.AddXY((Get-Date $task.Start), $y)
    $line.Points.AddXY((Get-Date $task.End), $y)

    # Points for click and tooltip
    $points = New-Object Windows.Forms.DataVisualization.Charting.Series
    $points.Name = "$($task.Project) - $($task.ProjectTask) Points"
    $points.ChartType = "Point"
    $points.MarkerStyle = "Circle"
    $points.MarkerSize = 12
    $points.Color = $projectColor[$task.Project]

    # Startpoint
    $startIndex = $points.Points.AddXY((Get-Date $task.Start), $y)
    $points.Points[$startIndex].Tag = $task.Jira
    $points.Points[$startIndex].Label = $task.ProjectTask
    $points.Points[$startIndex].ToolTip =
@"
$($task.Jira)
$($task.ProjectTask)

Start: $(([datetime]$task.Start).ToString("dd.MM.yyyy"))
End: $(([datetime]$task.End).ToString("dd.MM.yyyy"))
"@

    # Endpoint
    $endIndex = $points.Points.AddXY((Get-Date $task.End), $y)
    $points.Points[$endIndex].MarkerStyle = "Diamond"
    $chart.Series.Add($line)
    $chart.Series.Add($points)
}

$chart.Add_MouseClick({
	param($sEndr,$event)
	$result =
	$chart.HitTest(
		$event.X,
		$event.Y
	)

	 if(
		$result.ChartElementType -eq 
		[System.Windows.Forms.DataVisualization.Charting.ChartElementType]::DataPoint
	){
		$point = $result.Series.Points[$result.PointIndex]
		$jira = $point.Tag
		if($jira){
			Start-Process "$jiraBaseUrl$jira"
		}
	}
})

# Start
$form.Controls.Add($chart)
$form.ShowDialog()