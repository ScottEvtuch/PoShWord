<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
#>
function New-PWPassword
{
    [CmdletBinding(DefaultParameterSetName='CharacterLength')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Minimum length
        [Parameter(ParameterSetName='CharacterLength')]
        [Parameter()]
        [ValidateRange(1,64)]
        [int]
        $MinLength = 14,

        # Maximum length
        [Parameter(ParameterSetName='CharacterLength')]
        [Parameter()]
        [ValidateRange(1,64)]
        [int]
        $MaxLength = 18,

        # Number of passwords to generate
        [Parameter()]
        [ValidateRange(1,64)]
        [int]
        $Count = 12,

        # Punctuation options
        [Parameter()]
        [ValidateSet("None","Optional","Mandatory")]
        [String]
        $Punctuation = "Optional",

        # Punctuation options
        [Parameter()]
        [ValidateSet("None","Optional","Mandatory")]
        [String]
        $Terminator = "Optional"
    )

    Begin
    {
    }
    Process
    {
        # Check for logical consistency
        if ($MinLength -gt $MaxLength)
        {
            throw "Minimum length is greater than maximum length"
        }

        # Decide punctuation chance
        if ($Punctuation -ne "None")
        {
            # Determine average word count
            $AvgWordCount = ( $MinLength + $MaxLength ) / 2 / $WordInfo.Average
            Write-Debug "Expecting an average word count of $AvgWordCount"

            # Set chance of punctuation
            switch ($Punctuation)
            {
                'Optional'
                {
                    # Roughly every other password will contain punctuation
                    $PunctuationChance = 2147483647 * ( 0.5 / ($AvgWordCount -1 ) )
                }
                'Mandatory'
                {
                    # Roughly every password will contain punctuation
                    $PunctuationChance = 2147483647 * ( 1 / ($AvgWordCount -1 ) )
                }
            }
            Write-Debug "Chance of punctuation set to $($PunctuationChance / 2147483647)"
        }

        # Set up a variable for output
        $Passwords = @()

        # Loop through adding passwords
        do
        {
            $PasswordReset = $false
            $Password = ''
            $PasswordHasPunctuation = $false

            # Loop through adding words and punctuation
            do
            {
                # Add a word
                $Word = $WordList | Get-Random
                $Password += (Get-Culture).TextInfo.ToTitleCase($Word)

                # Roll for punctuation if enabled
                $WordHasPunctuation = $false
                if ($Punctuation -ne "None")
                {
                    if ($PunctuationChance -gt $(Get-Random))
                    {
                        # Add punctuation
                        $Password += $PunctuationList | Get-Random
                        $PasswordHasPunctuation = $true
                        $WordHasPunctuation = $true
                    }
                }

                # Check for invalid length
                if ($Password.length -gt $MaxLength)
                {
                    Write-Debug "Invalid this try ($Password), trying again"
                    $PasswordReset = $true
                }

                # Check for valid length
                switch ($Terminator)
                {
                    'None'
                    {
                        if ($Password.Length -ge $MinLength -and -not $WordHasPunctuation)
                        {
                            # Password already fits and does not have punctuation
                            Write-Debug "Valid password found ($Password), adding to list"
                            $Passwords += $Password
                            $PasswordReset = $true
                        }
                        elseif ($Password.Length -ge $($MinLength + 1) -and $WordHasPunctuation)
                        {
                            # Password would fit without the unecessary punctuation
                            Write-Debug "Removing punctuation from final word"
                            $Password = $Password.SubString(0,$Password.Length - 1)
                            Write-Debug "Valid password found ($Password), adding to list"
                            $Passwords += $Password
                            $PasswordReset = $true
                        }
                    }
                    'Optional'
                    {
                        if ($Password.Length -ge $MinLength)
                        {
                            if ($WordHasPunctuation)
                            {
                                # Passwords shouldn't end in punctuation that isn't a terminator
                                Write-Debug "Replacing random punctuation with terminator"
                                $Password = $Password.SubString(0,$Password.Length - 1) + $($TerminatorList | Get-Random)
                            }
                            Write-Debug "Valid password found ($Password), adding to list"
                            $Passwords += $Password
                            $PasswordReset = $true
                        }
                    }
                    'Mandatory'
                    {
                        if ($Password.Length -ge $MinLength -and $WordHasPunctuation)
                        {
                            # Password already fits and has a terminator that needs to be replaced
                            Write-Debug "Replacing random punctuation with terminator"
                            $Password = $Password.SubString(0,$Password.Length - 1) + $($TerminatorList | Get-Random)
                            Write-Debug "Valid password found ($Password), adding to list"
                            $Passwords += $Password
                            $PasswordReset = $true
                        }
                        elseif ($Password.Length -ge $($MinLength - 1) -and -not $WordHasPunctuation)
                        {
                            # Password would fit if we added a terminator
                            Write-Debug "Adding a terminator"
                            $Password += $TerminatorList | Get-Random
                            Write-Debug "Valid password found ($Password), adding to list"
                            $Passwords += $Password
                            $PasswordReset = $true
                        }
                    }
                }
                
            }
            while (!$PasswordReset)
        }
        while ($Passwords.Count -lt $Count)

        # Return the passwords
        return $Passwords
    }
    End
    {
    }
}