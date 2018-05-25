param($outDirectory = 'mdsite:\', $groupList = 'ps:\usergroup\userGroupList.txt')

#http://winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/   
#youtube feed https://support.google.com/youtube/answer/3250431?hl=en
#azpowershell feed https://www.youtube.com/feeds/videos.xml?channel_id=UC3RiZUhPQH9cANYnECWrbFA 
#markdown reference https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet#lists
Function Remove-InvalidFileNameChars {
    param(
      [Parameter(Mandatory=$true,
        Position=0,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
      [String]$Name
    )
  
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    $return = ($Name -replace $re)
    $return = $return -replace ',', ''
    $return = $return -replace '&', ""
    $return = $return -replace '|', ""
    
    $return
  }

Import-Module  MarkdownPS
$crlf = "`r"
$userGroups = get-content $groupList
push-location
cd $outdirectory
write-debug 'create usergroups file'
if(test-path .\toc.md)
{
  remove-item .\toc.md
  new-item .\toc.md
  "#### PowerShell UserGroup Links" | add-content .\toc.md  -Encoding UTF8 

  "- $(new-mdlink -text 'User Groups' -link usergroups.md)" | add-content .\toc.md  -Encoding UTF8

}
New-MDHeader -text "PowerShell User Groups" | set-Content .\usergroups.md
$crlf| add-content .\usergroups.md
foreach($u in $userGroups)
{
    $u1 = $u -split ','
    $usergroupFolder = ( ("$($U1[0])") -replace '"','')
    $userGroupFile =Remove-InvalidFileNameChars ( ("$($U1[0]).md") -replace '"','')
    
    $feed = Invoke-RestMethod -uri $u1[1]
    "    - $(New-MDLink -text "$($u1[0])" -link ($userGroupFile -replace ' ','%20'))"| add-content .\toc.md  -Encoding UTF8
    #$crlf | add-content .\toc.md
    $siteAuthor = $feed | Select-Object -first 1
    New-MDLink -Text $siteAuthor.author.name -Link $siteAuthor.author.uri | add-content .\usergroups.md -Encoding UTF8
    $crlf|Add-content .\usergroups.md
    $Links = @()
    
    foreach ($f in $feed)
    {
      [xml]$data = $f.OuterXML
      $filename = Remove-InvalidFileNameChars "$($data.entry.group.title).md"
      $filename = "$usergroupfolder\$filename"
      if(test-path $filename)
      {remove-item $filename -Force}
      New-Item $filename -Force
      $topicTitle = New-MDParagraph -Lines $data.entry.group.description
      $speakerThumbNail = new-mdimage -source $data.entry.group.thumbnail.url -Title $data.entry.group.title -AltText $data.entry.group.title  -Link "$($data.entry.id -replace 'yt:video:','https://www.youtube.com/watch?v=')"  #$data.entry.group.content.url
      New-MDHeader -Text $data.entry.group.title | add-content .\$filename
      $speakerThumbNail | add-content .\$filename -Encoding UTF8
      $topicTitle| Add-Content .\$filename -Encoding UTF8
      $file = $filename -replace '\\','/'
      $links +=  new-mdlink -text $data.entry.group.title -link "$($file -replace ' ','%20')"
      $links += "`r`n"
    }
    if(test-path .\$userGroupFile )
    {   
        remove-item .\$userGroupFile
    }
    new-item $userGroupFile -Force
    $links | Add-Content .\$userGroupFile -Encoding UTF8
}

pop-location

