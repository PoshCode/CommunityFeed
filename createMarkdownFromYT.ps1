#param($youtubeLink = 'https://www.youtube.com/feeds/videos.xml?channel_id=UCMhQH-yJlr4_XHkwNunfMog')

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
    return ($Name -replace $re)
  }
function Invoke-HTMLEncode
{ #https://stackoverflow.com/questions/2779594/alternative-to-system-web-httputility-htmlencode-decode

  param($string)
  if([string]::isNullorEmpty($string))
  { 
   $return = $null
  }
  $result = [system.text.stringbuilder]::new($string.length)
  foreach($ch in $string.ToCharArray()) 
  {
    if([byte][char]$ch -le [byte][char]'>')
    {
     switch ($ch)
     {
       '<' {
         $result.append("&lt;") | out-null
         break;
       }
       '>' {
        $result.append("&gt;")| out-null
        break;
      }
      '"' {
        $result.append("&quot;")| out-null
        break;
      }
      '&'{
        $result.append("&amp;")| out-null
        break;
      }
      ' '{
        $result.Append("%20;")|out-null
      }
      default {
        $result.append($ch)| out-null
        break;
      }
     } 
    }
    elseif([byte][char]$ch -ge 160 -and [byte][char]$ch -lt 256)
    {
      #result.Append("&#").Append(((int)ch).ToString(CultureInfo.InvariantCulture)).Append(';');
      $result.append("&#").append(([byte][char]$ch).toString([System.Globalization.CultureInfo]::InvariantCulture)).append(';') | out-null
    }
    else
    {
      $result.Append($ch) | out-null
    }
  }
  $result.ToString()
}
Import-Module  MarkdownPS
$crlf = "`r"
$userGroups = get-content ps:\usergroup\usergrouplist.txt
push-location
cd C:\inetpub\miis
write-debug 'create usergroups file'
if(test-path .\toc.md)
{
  remove-item .\toc.md
  new-item .\toc.md
  "#### PowerShell UserGroup Links" | add-content .\toc.md  -Encoding UTF8 
  #$crlf | add-content .\toc.md 
  "- $(new-mdlink -text "User Groups" -link usergroups.md)" | add-content .\toc.md  -Encoding UTF8
  #$crlf | add-content .\toc.md
}
New-MDHeader -text "PowerShell User Groups" | set-Content .\usergroups.md
$crlf| add-content .\userGroupList.txt
foreach($u in $userGroups)
{
    $u1 = $u -split ','
    $userGroupFile =Remove-InvalidFileNameChars ( ("$($U1[0]).md") -replace '"','')
    
    $feed = Invoke-RestMethod -uri $u1[1]
    "    - $(New-MDLink -text "$($u1[0])" -link ($userGroupFile -replace ' ','%20'))"| add-content .\toc.md  -Encoding UTF8
    #$crlf | add-content .\toc.md
    New-MDLink -Text $feed[0].author.name -Link $feed[0].author.uri | add-content .\usergroups.md -Encoding UTF8
    $crlf|Add-content .\usergroups.md
    $Links = @()
    
    foreach ($f in $feed)
    {
      [xml]$data = $f.OuterXML
      $filename = Remove-InvalidFileNameChars "$($data.entry.group.title).md"
      if(test-path $filename)
      {remove-item $filename -Force}
      New-Item $filename -Force
      $topicTitle = New-MDParagraph -Lines $data.entry.group.description
      $speakerThumbNail = new-mdimage -source $data.entry.group.thumbnail.url -Title $data.entry.group.title -AltText $data.entry.group.title  -Link $data.entry.group.content.url
      New-MDHeader -Text $data.entry.group.title | add-content .\$filename
      $speakerThumbNail | add-content .\$filename -Encoding UTF8
      $topicTitle| Add-Content .\$filename -Encoding UTF8
      $links +=  new-mdlink -text $data.entry.group.title -link "$($filename -replace ' ','%20')"
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
#$unicode = "[^\u0000-\u007F]"
