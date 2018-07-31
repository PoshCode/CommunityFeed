function Convert-Entry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [ValidateScript({
            if($_.name -ne "entry") { throw "The node isn't an entry" }
            if(!$_.title) { throw "The entry doesn't have a title" }
            # validate <media:group
            if(!$_.group -or $_.group.NamespaceURI -ne "http://search.yahoo.com/mrss/") { throw "The entry doesn't have a media:group" }
            if(!$_.group.description) { Write-Warning "The '$GroupName\$($_.Title)' entry doesn't have a description" }
            $true
        })]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Xml.XmlElement]$Entry
    )
    begin {
        $LastAuthor = $null
        # Create the folder if it's missing, but don't remove old entries
        if(!(Test-Path $GroupName -PathType Container)) {
            $GroupName = (ConvertTo-FileName $GroupName) -replace '\s+'
            if(!(Test-Path $GroupName -PathType Container)) {
                $null = New-Item -Path $GroupName -ItemType Directory
            }
        }
    }

    process {
        $Title = ConvertTo-FileName $Entry.title
        $FilePath = (Join-Path $GroupName $Title) + ".md"

        # Output markdown for the index page
        if ($Entry.Author.Uri -ne $LastAuthor) {
            $LastAuthor = $Entry.Author.Uri
            "`n## [Videos by $($Entry.Author.name)]($($Entry.Author.uri))`n`n"
        }
        "- [$($Entry.title)]($($FilePath -replace '\\','/'))`n"

        $thumbnail = "![$($Entry.title)]($($Entry.group.thumbnail.url) `"$($Entry.title)`")"

        Set-Content $FilePath @"
### $($Entry.title)

[$thumbnail](https://www.youtube.com/watch?v=$($Entry.videoId))

$($Entry.group.description)
"@ -Encoding UTF8

    }
}