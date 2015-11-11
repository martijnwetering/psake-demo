Include ".\helpers.ps1"

properties {
	$solutionDirectory = (Get-Item $solutionFile).DirectoryName
	$outputDirectory = "$solutionDirectory\.build"
	$temporaryOutputDirectory = "$outputDirectory\temp"

	$publishedNUnitTestDirectory = "$temporaryOutputDirectory\_PublishedNUnitTests"
	$testResultsDirectory = "$outputDirectory\TestResults"
	$NUnitTestResultsDirectory = "$testResultsDirectory\NUnit"
	
	$buildConfiguration = "Release"
	$buildPlatform = "Any CPU"

	$packagesPath = "$solutionDirectory\packages"
	$NUnitExe = (Find-PackagePath $packagesPath "NUnit.Runners") + "\Tools\nunit-console-x86.exe"
}

FormatTaskName "`r`n`r`n---------- Executing {0} Task ----------"

task default -depends Test

task Init -description "Initialises the build by removing previous artifacts
	and creating output directories" -requiredVariables outputDirectory, temporaryOutputDirectory {
	
	Assert -conditionToCheck ("Debug", "Release" -contains $buildConfiguration) -failureMessage "Invalid build configuration '$buildConfiguration' `
		valid values are 'Debug' or 'Release'"

	Assert -conditionToCheck ("x86", "x64", "Any CPU" -contains $buildPlatform) `
		-failureMessage "Invalid build platform '$buildPlatform'. Valid values are 'x86', 'x64' or 'Any CPU'"

	# Check that all tools are available
	Write-Host "Checking that all required tools are available"
	Assert (Test-Path $NUnitExe) "NUnit Console could not be found"
		
	# Remove previous build results
	if (Test-Path $outputDirectory)
	{
		Write-Host "Removing output directory located at $outputDirectory"
		Remove-Item $outputDirectory -Force -Recurse
	}

	Write-Host "Creating output directory located at ..\.build"
	New-Item $outputDirectory -ItemType Directory | Out-Null
		
	Write-Host "Creating temporary directory located at $temporaryOutputDirectory"
	New-Item $temporaryOutputDirectory -ItemType Directory | Out-Null	
}

task Compile -depends Init, Package-Restore {
	Write-Host "Building solution $solutionFile"
	Exec {
		msbuild $solutionFile "/p:Configuration=$buildConfiguration;Platform=$buildPlatform;OutDir=$temporaryOutputDirectory"
	}
}

task Package-Restore -description "Resotres all nuget packages for the projects in the solution" {
	Write-Host "Restoring nuget packages for packages in solution"
	Exec {
		Start-Process -FilePath $solutionDirectory\Build\nuget.exe -ArgumentList "restore $solutionFile"
	}
}

task Clean -description "Remove temporary files" {
	Write-Host "Executed Clean!"
}

task Test -depends Clean, Compile, TestNUnit, TestXUnit, TestMSTest -description "Run unit tests" {
	Write-Host "Executing tests!"
}

task TestNUnit -depends Compile -precondition { return Test-Path $publishedNUnitTestDirectory } -description "Runs NUnit tests" {
	$projects = Get-ChildItem $publishedNUnitTestDirectory

	# Create the test results directory if needed
	if (!(Test-Path $NUnitTestResultsDirectory))
	{
		Write-Host "Creating test results directory lacated at $NUnitTestResultsDirectory"
		New-Item -ItemType Directory -Path $NUnitTestResultsDirectory
	}

	# Get the list of test DLLs
	$testAssemblies = $projects | ForEach-Object { $_.FullName + "\bin\" + $_.Name + ".dll" }
	$testAssembliesParameter = [string]::Join(" ", $testAssemblies)

	Exec { &$NUnitExe $testAssembliesParameter /xml:$NUnitTestResultsDirectory\NUnit.xml /nologo /noshadow }
}

task TestXUnit -depends Compile -description "Runs xUnit tests" {

}

task TestMSTest -depends Compile -description "Runs MSTest tests" {

}