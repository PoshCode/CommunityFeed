function Update-FeedList {
    <#
    .SYNOPSIS
        Fetch YouTube channel feeds and generate webpages
    #>
    [CmdletBinding()]
    param(
        # The output location where markdown will be output
        [Parameter(Mandatory)]
        $Path,

        # The input file containing a list of YouTube feeds
        [Parameter(Mandatory)]
        $FeedList
    )

    $feeds = Import-Csv $FeedList

    Push-Location $Path -ErrorAction Stop
    Write-Debug 'Create index file'

    Set-Content index.md @"
# PowerShell UserGroup Links

"@  -Encoding UTF8

    $feeds | Update-Feed | Add-Content -Path index.md -Encoding UTF8

    Pop-Location
}