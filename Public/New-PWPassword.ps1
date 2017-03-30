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
            $PasswordHasPunctuation = $false
            $PasswordLengthValid = $false
            $Password = ''

            # Loop through adding words and punctuation
            do
            {
                # Add a word
                $Word = $WordList | Get-Random
                $Password += (Get-Culture).TextInfo.ToTitleCase($Word)

                # Add a terminator if we're above the minimum length
                switch ($Terminator)
                {
                    'Optional'
                    {
                        if ($Password.Length -ge $MinLength)
                        {
                            # Roughly every other password will have a terminator
                            if ((2147483647 / 2) -gt $(Get-Random))
                            {
                                Write-Debug "Adding a terminator"
                                $Password += $TerminatorList | Get-Random
                            }
                        }
                    }
                    'Mandatory'
                    {
                        if ($Password.Length -ge ($MinLength - 1))
                        {
                            # Password would fit if we added a terminator
                            Write-Debug "Adding a terminator"
                            $Password += $TerminatorList | Get-Random
                        }
                    }
                }

                # Roll for punctuation if enabled and length allows
                if ($Punctuation -ne "None" -and $Password.Length -lt $MinLength)
                {
                    Write-Debug "Rolling for punctuation"
                    if ($PunctuationChance -gt $(Get-Random))
                    {
                        Write-Debug "Adding punctuation"
                        $Password += $PunctuationList | Get-Random
                        $PasswordHasPunctuation = $true
                    }
                }

            }
            until ($Password.Length -ge $MinLength)

            if ($Password.length -gt $MaxLength)
            {
                Write-Debug "Length is invalid"
            }
            elseif ($Punctuation -eq 'Mandatory' -and !$PasswordHasPunctuation)
            {
                Write-Debug "Punctuation is invalid"
            }
            else
            {
                Write-Debug "Valid password found ($Password), adding to list"
                $Passwords += $Password
            }
        }
        while ($Passwords.Count -lt $Count)

        # Return the passwords
        return $Passwords
    }
    End
    {
    }
}