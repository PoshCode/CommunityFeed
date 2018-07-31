function Update-Feed {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Type,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Uri
    )
    begin {
        $LastType = $null
    }
    process {
        $Name = $Name -replace '"'
        $GroupName = ConvertTo-FileName $Name

        # Output markdown for the index page
        if ($Type -ne $LastType) {
            $LastType = $Type
            "`n## $Type`n`n"
        }
        "- [$Name]($(ConvertTo-FileName $Name).md)`n"

        # Create a new page
        Set-Content "$GroupName.md" @"
## $Name Videos

"@ -Encoding UTF8

        Invoke-RestMethod -uri $Uri |
            Convert-Entry -Group $GroupName |
            Add-Content "$GroupName.md" -Encoding UTF8

    }
}