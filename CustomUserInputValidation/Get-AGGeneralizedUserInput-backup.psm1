function Get-AGchooseFromTable
{
    param(
        $output, 
        $inputType,
        [switch]$displayProperties,
        $displayPropertyList
    )
    $results = @{}
    $i = 1
    foreach($row in $output)
    {
        $results[$i] = $row#.ItemArray
        $i++
    }
    $outs = @()
    $props = @{}
    foreach($key in $results.Keys)
    {  
        $props = @{}
        foreach($name in $results[$key].psobject.Properties.name)
        {
           $props[$name] = $results[$key].$name
        }
        $props["Index"] = $key
        $out = new-object psobject -Property $props
        $outs += $out
    }
    

    if($displayProperties)
    {
        $propertyString = @("Index")
        foreach($property in $outs[0].psobject.Properties.name)
        {
            foreach($properti in $displayPropertyList)
            {
                if($properti -eq $property -AND $property -ne "Index")
                {
                    $propertyString += $property
                    break
                }
            }
        }
    }
    else
    {
        $propertyString = @("Index")
        foreach($property in $outs[0].psobject.Properties.name)
        {
            if($property -ne "Index")
            {
                $propertyString += $property
            }
        }
    }

    $outs | Format-Table -Property $propertyString | Out-Host
    $selection = get-aginput -inputType $inputType -underValue $results.count
    if($selection -eq "b")
    {
        return $selection
    }
    else
    {
        $item = $results[[int]$selection]
        return $item
    }
}

function get-AGvalidateInput
{
    param($inputType, $underValue, $uInput)
    $validated = $true
    foreach($validationStep in $validationSteps)
    {
        if($inputInfo[$inputType].validationSteps.contains($validationStep))
        {
            if($validationStep -eq "underValue")
            {
                if([int64]$uInput -gt [int64]$underValue)
                {
                    $validated = $false
                }             
            }
            elseif($validationStep -eq "isTypeNumber")
            {
                $test = $null
                $global:Error.clear()
                try
                {
                    $test = [int64]$uInput
                }
                catch
                {
                    $e = $global:Error 
                }
                if($test -eq $null)
                {
                    $validated = $false
                }
            }
            elseif($validationStep -eq "positiveNumber")
            {
                if([int64]$uInput -lt 0)
                {
                    $validated = $false
                }
            }
            elseif($validationStep -eq "notZero")
            {
                if([int64]$uInput -eq 0)
                {
                    $validated = $false
                }
            }
            elseif($validationStep -eq "isLength")
            {
                if($uInput.length -ne $lengths[$inputType].lengthNeeded)
                {
                    $validated = $false
                }
            }
            elseif($validationStep -eq "startsWithS")
            {
                if($uInput[0] -ne "s" -AND $uInput[0] -ne "S")
                {
                    $validated = $false
                }
            }
            elseif($validationStep -eq "isInTable")
            {
                write-host "not implemented"
            }
            elseif($validationStep -eq "notBlank")
            {
                if(([string]$uInput).length -le 0)
                {
                    $validated = $false
                }
            }
            elseif($validationStep -eq "equalsCodeWord")
            {
                if($uInput -eq "")
                {
                    $modifiedInput = "blank"
                }
                else
                {
                    $modifiedInput = $uInput
                }
                if($codewords[$inputType].codeWord.contains($modifiedInput))
                {
                    $validated = $true
                    return $validated
                }
            }
        }
    }
    return $validated
}

function get-AGinput{
    param($inputType, $underValue)
    do{
		$writeString = $inputInfo[$inputType].inputString.replace("``n", "`n").replace("``r", "`r").replace("``t", "`t")
        [console]::beep(5000,500)
		write-host $writeString -nonewline -backgroundcolor "red"
        $uinput = read-host " "
        $validated = get-AGvalidateInput -inputType $inputType -underValue $underValue -uinput $uInput
        if(!$validated)
        {
            [console]::beep(1000,500)
            write-host $inputInfo[$inputType].tryAgainString
        }
    }while(!$validated)
    return $uInput
}
Import-Module Get-AGSharedHelperFunctions -force

#need to put ' in the CSV for an empty value to be read
$configPath = (Get-Module -ListAvailable Get-AGGeneralizedUserInput).path
$configPath = $configPath.Substring(0,$configPath.LastIndexOf("\")) + "\InputConfig"
$lengths = import-csv ($configPath + "\lengthRequirements.csv")
$lengths = Get-AGcsvToHashtable -csv $lengths -key "Name"
$inputInfo = import-csv ($configPath + "\inputInfo.csv")
$inputInfo = Get-AGcsvToHashtable -csv $inputInfo -key "Name"
$codewords = import-csv ($configPath + "\codewords.csv")
$codewords = Get-AGcsvToHashtable -csv $codewords -key "Name"

$validationSteps = @(
"equalsCodeWord",
"notBlank",
"isTypeNumber",
"underValue",
"isLength",
"startsWithS",
"isInTable",
"positiveNumber",
"notZero"
)