cls

Remove-Module [p]sake

$psakeModule = (Get-ChildItem (".\Build\psake.psm1")).FullName | Sort-Object $_ | Select-Object -last 1

Import-Module $psakeModule

Invoke-psake -buildFile .\Build\default.ps1 -taskList Test `
-properties @{ 
	"buildConfiguration" = "Release"
	"buildPlatform" = "Any CPU" } `
-parameters @{"solutionFile" = "..\psake.sln" } `
-framework 4.5.2

Write-Host "Build exit code: $lastExitCode"