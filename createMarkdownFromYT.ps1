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
    $outDirectory = 'mdsite:\',

    # The input file containing a list of YouTube feeds
    $groupList = "$PSScriptRoot\UserGroupList.csv"
)
# Temporarily dot-sourcing while converting
. $PSScriptRoot\Source\ConvertTo-FileName.ps1

$userGroups = Import-Csv $groupList

push-location
cd $outdirectory
write-debug 'create usergroups file'
if(test-path .\toc.md)
{
  remove-item .\toc.md
  new-item .\toc.md
  "#### PowerShell UserGroup Links" | add-content .\toc.md  -Encoding UTF8
  "- [User Groups](usergroups.md)" | add-content .\toc.md  -Encoding UTF8

}

"# PowerShell User Groups" | set-Content .\usergroups.md -Encoding UTF8
add-content "" .\usergroups.md -Encoding UTF8
foreach($u in $userGroups)
{
    $usergroupFolder = ( ("$($U.Name)") -replace '"','')
    $userGroupFile = Remove-InvalidFileNameChars ( ("$($U.Name).md") -replace '"','')

    $feed = Invoke-RestMethod -uri $u.Url
    add-content .\toc.md "    - [$($U.Name)]($($userGroupFile -replace ' ','%20'))" -Encoding UTF8
    # add-content "" .\toc.md
    $siteAuthor = $feed | Select-Object -first 1
    if($u.Url -match 'playlist_id=')
    {
      $siteAuthorText = $U.Name
      $playlistId = ($u.Url -split 'playlist_id=')[1]
      $siteAuthorLink = "https://www.youtube.com/results?search_query=$playlistid "
    }
    else {
      $siteAuthorText = $siteAuthor.author.name
      $siteAuthorLink = $siteAuthor.author.uri
    }

    add-content .\usergroups.md "[$siteAuthorText]($siteAuthorLink)" -Encoding UTF8
    Add-Content .\usergroups.md "" -Encoding UTF8
    $Links = @()

    foreach ($f in $feed)
    {
      [xml]$data = $f.OuterXML
      $filename = Remove-InvalidFileNameChars "$($data.entry.group.title).md"
      $filename = "$usergroupfolder\$filename"
      if(test-path $filename)
      {remove-item $filename -Force}
      New-Item $filename -Force
      $topicTitle = "`n`n" + $($data.entry.group.description -join "`n")
      $speakerThumbNail = "[![$($data.entry.group.title)]($($data.entry.group.thumbnail.url) `"$($data.entry.group.title)`")](https://www.youtube.com/watch?v=$($data.entry.id -replace 'yt:video:'))"  #$data.entry.group.content.url
      add-content .\$filename ("#### " + $data.entry.group.title) -Encoding UTF8
      add-content .\$filename $speakerThumbNail -Encoding UTF8
      Add-content .\$filename "" -Encoding UTF8
      Add-Content .\$filename $topicTitle  -Encoding UTF8
      $file = $filename -replace '\\','/'
      $links += "[$($data.entry.group.title)]($($file -replace ' ','%20'))`n"
    }
    if(test-path .\$userGroupFile )
    {
        remove-item .\$userGroupFile
    }
    new-item $userGroupFile -Force
    add-content .\$userGroupFile "#### $usergroupFolder Links" -Encoding UTF8
    Add-Content .\$userGroupFile $links -Encoding UTF8
}

pop-location

