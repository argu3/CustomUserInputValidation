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

function Get-AGvalidateInput
{
    param([string]$inputType, [int]$underValue, $uInput)
    if($inputInfo[$inputType].validationSteps.contains("equalsCodeWord"))
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
    if($inputInfo[$inputType].validationSteps.contains("notBlank"))
    {
        if(([string]$uInput).length -le 0)
        {
            return $false
        }
    }
    if($inputInfo[$inputType].validationSteps.contains("isTypeNumber"))
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
            return $false
        }
        else
        {
            if($inputInfo[$inputType].validationSteps.contains("underValue"))
            {
                if([int64]$uInput -gt [int64]$underValue)
                {
                    return $false
                }             
            }

            if($inputInfo[$inputType].validationSteps.contains("positiveNumber"))
            {
                if([int64]$uInput -lt 0)
                {
                    return $false
                }
            }
            if($inputInfo[$inputType].validationSteps.contains("notZero"))
            {
                if([int64]$uInput -eq 0)
                {
                    return $false
                }
            }
        }
    }
    elseif($inputInfo[$inputType].validationSteps.contains("noNumbers"))
    {
        if($uInput -match "[0-9]")
        {
            return $false
        }
    }
    if($inputInfo[$inputType].validationSteps.contains("noSpecialCharacters"))
    {
        $len = $uInput.length
        if($uInput -match '^[a-zA-Z0-9]{6}$')
        {
            return $false
        }
    }
    if($inputInfo[$inputType].validationSteps.contains("isLength"))
    {
        if($uInput.length -ne $lengths[$inputType].lengthNeeded)
        {
            return $false
        }
    }
    if($inputInfo[$inputType].validationSteps.contains("startsWithS"))
    {
        if($uInput[0] -ne "s" -AND $uInput[0] -ne "S")
        {
            return $false
        }
    }
    if($inputInfo[$inputType].validationSteps.contains("regex"))
    {
        $patterns = $regex[$inputType].regex.split("|")
        foreach($pattern in $patterns)
        {
            if($uInput -notmatch $pattern)
            {
                return $false
            }
        }
    }
    if($inputInfo[$inputType].validationSteps.contains("function"))
    {
        $functionList = $functions[$inputType].functions.split("|")
        foreach($function in $functionList)
        {
            if(!(& $function -uinput $uinput))
            {
                return $false
            }
        }
    }
    return $true
}

function Get-AGinput{
    param([string]$inputType, [int]$underValue, [system.consolecolor]$backgroundcolor, [system.consolecolor]$foregroundcolor, [bool]$newLine, [bool]$noColon, [bool]$beep = $true)
    if($inputInfo[$inputType] -eq $null)
    {
        Read-AGhost "Not a valid type" -backgroundcolor Red
    }
    else
    {
        do{
		    $writeString = $inputInfo[$inputType].inputString.replace("``n", "`n").replace("``r", "`r").replace("``t", "`t")
            if($beep){[console]::beep(5000,500)}
		    Read-AGhost -prompt $writeString -NewLine $newLine -foregroundcolor $foregroundcolor -backgroundcolor $backgroundcolor -noColon $noColon
            $validated = get-AGvalidateInput -inputType $inputType -underValue $underValue -uinput $uInput
            if(!$validated)
            {
                if($beep){[console]::beep(1000,500)}
                write-host $inputInfo[$inputType].tryAgainString
            }
        }while(!$validated)
    }
    return $uInput
}

function Get-AGConfigValidation{
    foreach($item in $inputInfo.keys)
    {
        
        if($inputInfo[$item].validationSteps.length -eq 0)
        {
            write-host $item "has no validation steps!S" -BackgroundColor Red
        }
        else
        {
            if($inputInfo[$item].validationSteps.contains("equalsCodeWord") -AND $codewords[$item].codeWord.length -le 0)
            {
                Write-Host $item "needs a code word" -BackgroundColor Red
            }
            if($inputInfo[$item].validationSteps.contains("isLength"))
            {
                 $test = $null
                $global:Error.clear()
                try
                {
                    $test = [int64]$lengths[$item].lengthNeeded
                }
                catch
                {
                    $e = $global:Error 
                }
                if($test -eq $null)
                {
                    Write-Host $item "needs a valid length" -BackgroundColor Red
                }
                elseif($test -eq 0)
                {
                    Write-Host $item "needs a valid length" -BackgroundColor Red
                }       
            }
            if(!$inputInfo[$item].validationSteps.contains("isTypeNumber") -AND ($inputInfo[$item].validationSteps.contains("notZero") -OR $inputInfo[$item].validationSteps.contains("positiveNumber") -OR $inputInfo[$item].validationSteps.contains("underValue")))
            {
                write-host $item "needs to include 'isTypeNumber' if it includes any other number-based checks" -BackgroundColor Red
            }
        }
        if($inputInfo[$item].inputString.length -eq 0)
        {
            write-host $item "is missing an input string" -BackgroundColor Yellow
        }
        if($inputInfo[$item].tryAgainString.length -eq 0)
        {
            write-host $item "is missing an input string" -BackgroundColor Yellow
        }
    }
}

function Get-AGValidationStepOptions
{
write-host "
current validationSteps:
    equalsCodeWord
    notBlank
    isTypeNumber 
        #these are a subset of isTypeNumber
        underValue
        isInTable
        positiveNumber
        notZero
    isLength
    startsWithS
    notZero
    noSpecialCharacters
    noNumbers
    function
    regex
"
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
$functions = import-csv ($configPath + "\functions.csv")
$functions = Get-AGcsvToHashtable -csv $functions -key "Name"
$regex = import-csv ($configPath + "\regex.csv")
$regex = Get-AGcsvToHashtable -csv $regex -key "Name"

