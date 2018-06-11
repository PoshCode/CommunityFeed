param($moduleName = 'myModule', $modulePath = 'c:\users\me\mymodule',$outputPath = "C:\temp\$moduleName")

ipmo -name $moduleName -force -ea Ignore
if(get-module -Name $modulename)
{
    $functions = get-command -Module $modulename 
}
else
{
    import-module "$modulepath\$modulename" -Force
    $functions = get-command -Module $modulename 
}
if(! (test-path $outputPath -PathType Container))
{
    new-item $outputPath -ItemType Directory
}
foreach($f in $functions)
{
    
    $filename = "$outputPath\$($f.name).ps1"
    $help = get-help -name $f.name 
    $help | out-file -FilePath $filename 
    $h = get-content $filename 
    $h | foreach{write-output "# $($_)" }>$filename
    "function $($f.name) `r`n{" | add-content $filename 
    $f.scriptblock | add-content $filename 
    "`r`n}" | add-content $filename 
}
