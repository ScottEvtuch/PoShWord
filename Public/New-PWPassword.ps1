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
        $MinLength = 12,

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
        $Count = 12
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

        # Set up a variable for output
        $Passwords = @()

        # Loop through adding words
        $Password = ''
        do
        {
            # Add a word
            $Word = $WordList | Get-Random
            $Password += (Get-Culture).TextInfo.ToTitleCase($Word)

            # Check for invalid
            if ($Password.length -gt $MaxLength)
            {
                Write-Debug "Invalid this try ($Password), clearing variable"
                $Password = ''
            }

            # Check for valid
            if ($Password.Length -ge $MinLength)
            {
                Write-Debug "Valid password found ($Password), adding to list"
                $Passwords += $Password
                $Password = ''
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