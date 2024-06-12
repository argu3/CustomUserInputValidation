# CustomUserInputValidation
User input validation module for powershell

This is just copied from the module help file:


NAME
    Get-AGGeneralizedUserInput

SYNOPSIS
    This module allows for the creation of configurable input types using the csvs in the "InputConfig" folder. It is designed to be used in conjunction with any module that accepts user input.

OVERVIEW
    Functions:
        "Get-AGinput" accepts a user's input; validates it; and returns it. It's used the same way read-host would be used.
            -inputType [string]: any of the named inputs in .\InputConfig\inputInfo.csv
            -underValue [int]: used if the input needs to be under a certain value. Is checked if specified in inputInfo.csv
            -backgroundColor [system.consolecolor]: passes a color to write-host -backgroundColor
            -foregroundColor [system.consolecolor]: passes a color to write-host -foregroundColor
            -newLine [bool]: adds a new line after the user prompt
            -noColon [bool]: removes the colon from the user prompt
            -beep [bool]: adds a console beep when user is prompted
        "Get-AGvalidateInput" is used by "Get-AGInput" to perform input validation. It can also be used independedntly
            -inputType [string]: any of the named inputs in .\InputConfig\inputInfo.csv
            -underValue [int]: used if the input needs to be under a certain value. Is checked if specified in inputInfo.csv
            -uInput: the user input to be validated
        "Get-AGchooseFromTable" is used to let a user pick an item from a list via index
            -output [object]: the list that the user is picking from 
            -inputType [string]: any of the named inputs in .\InputConfig\inputInfo.csv
            -displayProperties [switch]: used if the object should only show certain properties to the user
            -displayPropertyList @(): used to list the properties when -displayProperties is used
    Helper functions:
        "Get-AGConfigValidation" validates the configuration csvs.
        "Get-AGValidationStepOptions" shows the optional validation steps for a new input type
    Config files:
        "inputInfo" is used to define a new type of input
            Name: the name used with -inputType
            inputString: What the user is prompted with for this input type
            tryAgainString: What the user is prompted with if input validation fails
            validationSteps: A pipe-delimited list of validation steps from the list found with "Get-AGValidationStepOptions"
        "codeWords" is used in conjunction with "inputInfo" to add input options that ignore other validation steps
            Name: the name used with -inputType, needs to be present in inputInfo
            codeWord: A pipe-delimited list of accepted inputs
        "lengths" is used to set the length of inputs which use the "isLength" validation step 
        "functions" is used to set the functions that will determine the input's validity
        "regex" is used to set the regex patterns for the input to be matched against

EXAMPLES
    need to add examples 

KEYWORDS
    
