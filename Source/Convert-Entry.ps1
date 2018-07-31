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
            if(!$_.group.description) { throw "The entry doesn't have a description" }
        })]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Xml.XmlElement]$Entry
    )
    begin {
        if(!(Test-Path $GroupName -PathType Container)) {
            $GroupName = ConvertTo-FileName $GroupName
            if(!(Test-Path $GroupName -PathType Container)) {
                $null = New-Item -Path $GroupName -ItemType Directory
            }
        }
    }

    process {
        $Title = ConvertTo-FileName $Entry.title
        $FilePath = (Join-Path $GroupName $Title) + ".md"

        # return an object representing this entry
        [PSCustomObject]@{
            Title = $Entry.title
            Path = $FilePath
            Author = [PSCustomObject]@{
                Name = $Entry.Author.Name
                Uri = $Entry.Author.Uri
            }
        }

        $thumbnail = "![$($Entry.title)]($($Entry.group.thumbnail.url) `"$($Entry.title)`")"

        Set-Content $FilePath @"
### $($Entry.title)

[$thumbnail](https://www.youtube.com/watch?v=$($Entry.videoId))

$($Entry.group.description)
"@ -Encoding UTF8

    }
}