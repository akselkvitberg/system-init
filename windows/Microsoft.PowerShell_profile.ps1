[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
Write-Host "Loading PowerShell $($PSVersionTable.PSVersion)..." -ForegroundColor 3
Write-Host

function Run-Step([string] $Description, [ScriptBlock]$script)
{
  Write-Host  -NoNewline "Loading " $Description.PadRight(20)
  $measurement = Measure-Command {
    & $script
  }
  Write-Host "`u{2705}" -NoNewline # checkmark emoji
  Write-Host "`t $($measurement.Milliseconds) ms"
}

Run-Step "oh-my-posh" {
    oh-my-posh init pwsh --config (Join-path (Split-Path $PROFILE) poshTheme.json) | Invoke-Expression
    #& (Join-path (Split-Path $PROFILE) \Modules\oh-my-posh\oh-my-posh.exe) --init --shell pwsh --config (Join-path (Split-Path $PROFILE) PoshThemes\paradox2.json) | Invoke-Expression
    #Import-Module oh-my-posh
}

# Run-Step " - Setting prompt" {
#     Set-PoshPrompt (Join-path (Split-Path $PROFILE) PoshThemes\paradox2.json)
# }

Run-Step "Terminal-Icons" {
    Import-Module Terminal-Icons
}

Import-Module Go
Import-Module git-tabcompletion

function vs
{
    Get-ChildItem *.sln | Invoke-Item
}

function Edit-File ([Parameter(ValueFromPipeline)][string[]]$path, $pattern, $replacement)
{
    $data = Get-Content $path
    $data -replace $pattern, $replacement | Set-Content $path
}

function Nano ($path) {
    if($path) {
        $path = $path.Replace(".\", "").Replace("\", "/")
    }
    bash -c "nano $path"
}

function Rider ($path) {
    if($path){

    }
    else {
        $path = "."
        $solutions = get-ChildItem *.sln
        if($solutions) {
            $path = $solutions[0].Name
        }
        else {
            $csproj = get-ChildItem *.csproj
            if($csproj) {
                $path = $csproj[0].Name
            }
        }
        
    }
    # $rider = Get-ChildItem "C:\Users\aksel\AppData\Local\JetBrains\Installations\*\bin\rider64.exe"
    Start-Process 'rider.cmd' $path
}

function Ridereap ($path) {
    if($path){

    }
    else {
        $path = "."
        $solutions = get-ChildItem *.sln
        if($solutions) {
            $path = $solutions[0].Name
        }
        else {
            $csproj = get-ChildItem *.csproj
            if($csproj) {
                $path = $csproj[0].Name
            }
        }
        
    }
    # $rider = Get-ChildItem "C:\Users\aksel\AppData\Local\JetBrains\Installations\*\bin\rider64.exe"
    Start-Process 'ridereap.cmd' $path
}


Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# Run-Step "dotnet suggest autocomplete" {
#     if (Get-Command "dotnet-suggest" -errorAction SilentlyContinue)
#     {
#         $availableToComplete = (dotnet-suggest list) | Out-String
#         $availableToCompleteArray = $availableToComplete.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)

#         Register-ArgumentCompleter -Native -CommandName $availableToCompleteArray -ScriptBlock {
#             param($wordToComplete, $commandAst, $cursorPosition)
#             $fullpath = (Get-Command $commandAst.CommandElements[0]).Source

#             $arguments = $commandAst.Extent.ToString().Replace('"', '\"')
#             dotnet-suggest get -e $fullpath --position $cursorPosition -- "$arguments" | ForEach-Object {
#                 [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
#             }
#         }    
#     }
#     else
#     {
#         "Unable to provide System.CommandLine tab completion support unless the [dotnet-suggest] tool is first installed."
#         "See the following for tool installation: https://www.nuget.org/packages/dotnet-suggest"
#     }

#     $env:DOTNET_SUGGEST_SCRIPT_VERSION = "1.0.2"

# }

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}