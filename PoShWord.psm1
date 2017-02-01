# Import the word list

    try
    {
        $WordList = Import-Clixml -Path "$PSScriptRoot\Wordlist.xml"

        $WordInfo = $WordList | Measure-Object -Average -Maximum -Minimum -Property length

        Write-Verbose "Average word length is $($WordInfo.Average)"
    }
    catch
    {
        throw "Failed to import word list: $_"
    }

# Setup variables

    $PunctuationList = @(',',';',':','.')

    $TerminatorList = @('.','?','!')

    $ExportParams = @{}

#region Public Functions

    # Name of the folder for public function ps1 files
    $PublicFunctionFolder = "Public"

    # Setup variables
    $PublicFunctionPath = "$PSScriptRoot\$PublicFunctionFolder"
    $PublicFunctions = @()
    $PublicAliases = @()

    # Get all of the public function files we'll be importing
    Write-Verbose "Searching for scripts in $PublicFunctionPath"
    $PublicFunctionFiles = Get-ChildItem -File -Filter *-*.ps1 -Path $PublicFunctionPath -Recurse -ErrorAction Continue
    Write-Debug "Found $($PublicFunctionFiles.Count) function files in $PublicFunctionPath"

    # Iterate through each of the public function files
    foreach ($PublicFunctionFile in $PublicFunctionFiles)
    {
        $PublicFunctionName = $PublicFunctionFile.BaseName
        Write-Verbose "Importing function $PublicFunctionName"
        try
        {
            # Dot source the file and extract the function name and any aliases
            . $PublicFunctionFile.FullName
            $PublicFunctions += $PublicFunctionName
            $PublicFunctionAliases = Get-Alias -Definition $PublicFunctionName -Scope Local -ErrorAction SilentlyContinue
            Write-Debug "Aliases for $PublicFunctionName`: $PublicFunctionAliases"
            $PublicAliases += $PublicFunctionAliases
        }
        catch
        {
            Write-Error "Failed to import $($PublicFunctionFile): $_"
        }
    }

    # Add to the export parameters
    $ExportParams.Add("Function",$PublicFunctions)
    $ExportParams.Add("Alias",$PublicAliases)

#endregion

#region Private Functions

    # Name of the folder for private function ps1 files
    $PrivateFunctionFolder = "Private"

    # Setup variables
    $PrivateFunctionPath = "$PSScriptRoot\$PrivateFunctionFolder"

    # Get all of the private function files we'll be importing
    Write-Verbose "Searching for scripts in $PrivateFunctionPath"
    $PrivateFunctionFiles = Get-ChildItem -File -Filter *-*.ps1 -Path $PrivateFunctionPath -Recurse -ErrorAction Continue
    Write-Debug "Found $($PrivateFunctionFiles.Count) function files in $PrivateFunctionPath"

    # Iterate through each of the private function files
    foreach ($PrivateFunctionFile in $PrivateFunctionFiles)
    {
        $PrivateFunctionName = $PrivateFunctionFile.BaseName
        Write-Verbose "Importing function $PrivateFunctionName"
        try
        {
            # Dot source the file
            . $PrivateFunctionFile.FullName
        }
        catch
        {
            Write-Error "Failed to import $PrivateFunctionFile`: $_"
        }
    }

#endregion

# Export the public items

    Export-ModuleMember @ExportParams