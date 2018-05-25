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