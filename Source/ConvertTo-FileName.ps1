function ConvertTo-FileName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name
    )
    begin {
        $characters = [RegEx]::Escape( -join ([IO.Path]::GetInvalidFileNameChars() + @(',','&')))
        $characters = [RegEx]::new("[$characters]", "Compiled")
    }
    process {
        $Name -replace $characters
    }
}