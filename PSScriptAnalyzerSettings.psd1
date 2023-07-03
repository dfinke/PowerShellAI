# https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/readme?view=ps-modules
@{
    IncludeDefaultRules = $true
    IncludeRules        = @(
        'PSAlignAssignmentStatement',
        'PSAvoidLongLines',
        'PSAvoidUsingDoubleQuotesForConstantString',
        'PSPlaceOpenBrace',
        'PSPlaceCloseBrace',
        'PSUseConsistentIndentation',
        'PSUseCorrectCasing'
    )

    Rules               = @{
        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSAvoidLongLines           = @{
            Enable            = $true
            MaximumLineLength = 120
        }

        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
    }
}
