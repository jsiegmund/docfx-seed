
<#
.SYNOPSIS
    Builds documentation-as-code samples into static HTML output

.NOTES
    Author           : Jasper Siegmund - @jsiegmund

.LINK
    http://www.github.com/jsiegmund/documentation-as-code
#>

param (
  [Switch]$Serve = $false,
  [Switch]$SkipImages = $false
)

# Set variables
$scriptsPath = $PSScriptRoot
$plantumlExePath = "plantuml.exe"
$diagramsOutputFolder = "$scriptsPath/articles/images/diagrams"

# Image generation might be excluded to optimize build time when diagrams didn't change
if (-not $SkipImages.IsPresent) {

  $plantumlFiles = Get-ChildItem "articles/diagrams/*.puml"
  Write-Host "Converting $($plantumlFiles.Count) Plant-UML .puml files to images." -ForegroundColor Yellow

  # Run plantuml for every .puml file found in the diagrams folder
  $plantumlFiles | ForEach-Object {
    $fileFullName = $_.FullName

    $plantumlArgs = @(    
      "$fileFullName",
      "-o $diagramsOutputFolder"
    )

    # Starts the actual pandoc process
    Start-Process $plantumlExePath -ArgumentList $plantumlArgs -NoNewWindow -Wait
  }
}

Write-Host "Kicking off docfx build process." -ForegroundColor Yellow

$docfxArgs = @(    
  "docfx.json"
)

# Add '--serve' to arguments in order to start serving the site in place
if ($Serve.IsPresent) {

  Write-Output "PRESENT"
  $docfxArgs = $docfxArgs + "--serve"
}

# Start the make process which uses Sphynx to convert RST to HTML
Start-Process "docfx" -ArgumentList $docfxArgs -NoNewWindow -Wait