<#
    .SYNOPSIS
        Fetch YouTube channel feeds and generate webpages

    .NOTES
        http://winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/
        youtube feed https://support.google.com/youtube/answer/3250431?hl=en
        azpowershell feed https://www.youtube.com/feeds/videos.xml?channel_id=UC3RiZUhPQH9cANYnECWrbFA
        markdown reference https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#lists
#>
[CmdletBinding()]
param(
    # The output location where markdown will be output
    $Path = "$PSScriptRoot\Output",

    # The input file containing a list of YouTube feeds
    $groupList = "$PSScriptRoot\UserGroupList.csv"
)

# Temporarily dot-sourcing while converting
. $PSScriptRoot\Source\ConvertTo-FileName.ps1
. $PSScriptRoot\Source\Convert-Entry.ps1
. $PSScriptRoot\Source\Update-Feed.ps1
. $PSScriptRoot\Source\Update-FeedList.ps1

if(!(Test-Path $Path)) {
    New-Item $Path -ItemType Directory -Confirm
}

Update-FeedList $Path $groupList