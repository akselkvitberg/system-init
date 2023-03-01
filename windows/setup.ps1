Write-Host Installing winget packages

$packages = @(
    # SDKs
    'Microsoft.DotNet.SDK.7',
    'Python.Python.3',

    # Dev Tools
    'Git.Git',
    'LINQPad.LINQPad.7',
    'Microsoft.WindowsTerminal.Preview',
    'Microsoft.PowerShell',
    'Docker.DockerDesktop',
    'icsharpcode.ILSpy',
    'JanDeDobbeleer.OhMyPosh',
    'Anaconda.Anaconda3',
    'Caphyon.AdvancedInstaller',
    'Postman.Postman',
    '9WZDNCRDMDM3', # Nuget package explorer
    '9P7KNL5RWT25', # Sysinternals

    # Security
    'GnuPG.Gpg4win',
    'Yubico.YubikeyManager',
    'Yubico.YubiKeyPersonalizationTool',
    'Bitwarden.Bitwarden',

    # Editors
    'Microsoft.VisualStudioCode',
    'Microsoft.VisualStudio.2022.Professional',
    'JetBrains.Toolbox',
    
    # Database
    #'Microsoft.SQLServer.2019.Developer',
    'Microsoft.AzureDataStudio',
    'Microsoft.SQLServerManagementStudio',

    # Chat
    'Microsoft.Teams',
    'Telegram.TelegramDesktop',
    'Discord.Discord',
    'OpenWhisperSystems.Signal',
    'SlackTechnologies.Slack'

    # Misc
    'Microsoft.Powershell.Preview',
    'Microsoft.PowerToys',
    'Microsoft.OneDrive',
    'NickeManarin.ScreenToGif',
    #'Microsoft.Office',
    '7zip.7zip',
    #'Spotify.Spotify',
    'QL-Win.QuickLook'
    #'Logitech.OptionsPlus'
    'Nvidia.GeForceExperience'
)

$packages | ForEach-Object { 
    Write-Host "winget install --id $_"
    winget install --id $_ 
}

Write-Host Installing PowerShell Modules

function Install-PowerShellModule {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $ModuleName,

        [ScriptBlock]
        [Parameter(Mandatory = $false)]
        $PostInstall = {}
    )

    if (!(Get-Command -Name $ModuleName -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $ModuleName"
        Install-Module -Name $ModuleName -Scope CurrentUser -Force
        Import-Module $ModuleName

        Invoke-Command -ScriptBlock $PostInstall
    }
    else {
        Write-Host "$ModuleName was already installed, skipping"
    }
}

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

Install-PowerShellModule 'Posh-Git'
Install-PowerShellModule 'PSProfiler'
#Install-PowerShellModule 'Go'
Install-PowerShellModule 'ImportExcel'
Install-PowerShellModule 'PSReadLine'
Install-PowerShellModule 'Terminal-Icons'
#Install-PowerShellModule 'nvm' {
#    Install-NodeVersion latest
#    Set-NodeVersion -Persist User latest
#}

Write-Host Setting up dotfiles

$repoBaseUrl = 'https://raw.githubusercontent.com/akselkvitberg/system-init/main'

Invoke-WebRequest -Uri "$repoBaseUrl/common/.gitconfig" -OutFile (Join-Path $env:USERPROFILE '.gitconfig')
Invoke-WebRequest -Uri "$repoBaseUrl/windows/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
Invoke-WebRequest -Uri "$repoBaseUrl/windows/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE.Replace("WindowsPowerShell", "PowerShell")
Invoke-WebRequest -Uri "$repoBaseUrl/windows/poshTheme.json" -OutFile (Split-Path $PROFILE.Replace("WindowsPowerShell", "PowerShell")) + "poshTheme.json"
Invoke-WebRequest -Uri "$repoBaseUrl/windows/profiles.json" -OutFile "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

Write-Host Installing dotnet global tools
dotnet tool install -g dotnet-ef
dotnet tool install -g dotnet-suggest
dotnet tool install -g dotnet-serve
dotnet tool install -g dotnet-project-licenses
dotnet tool install -g dotnet-outdated-tool
dotnet tool install -g microsoft.dotnet-httprepl


Write-Host Installing additional software

wsl --install
#wsl --exec "curl $repoBaseUrl/linux/setup.sh | bash"

Write-Host Installing VS Code extensions
code --install-extension adpyke.codesnap
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension bradlc.vscode-tailwindcss
code --install-extension cake-build.cake-vscode
code --install-extension csstools.postcss
code --install-extension DotJoshJohnson.xml
code --install-extension dracula-theme.theme-dracula
code --install-extension eamodio.gitlens
code --install-extension EditorConfig.EditorConfig
code --install-extension formulahendry.auto-close-tag
code --install-extension formulahendry.auto-rename-tag
code --install-extension humao.rest-client
code --install-extension Ionide.Ionide-fsharp
code --install-extension ms-azuretools.vscode-azurefunctions
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.dotnet-interactive-vscode
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension ms-toolsai.jupyter-keymap
code --install-extension ms-toolsai.jupyter-renderers
code --install-extension ms-toolsai.vscode-jupyter-powertoys
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.hexeditor
code --install-extension ms-vscode.powershell
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension mvllow.rose-pine
code --install-extension pflannery.vscode-versionlens
code --install-extension PKief.material-icon-theme
code --install-extension rangav.vscode-thunder-client
code --install-extension RobbOwen.synthwave-vscode
code --install-extension tanhakabir.rest-book
code --install-extension tht13.html-preview-vscode
code --install-extension Tyriar.luna-paint
code --install-extension VisualStudioExptTeam.vscodeintellicode
code --install-extension Vue.volar


function Install-DelugiaCode {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $font)
    Write-Host Installing $font
    $tag = (Invoke-WebRequest "https://api.github.com/repos/adam7/delugia-code/releases" | ConvertFrom-Json)[0].tag_name
    $download = "https://github.com/adam7/delugia-code/releases/download/$tag/$font.zip"
    Invoke-WebRequest $download -Out "$font.zip"
    Expand-Archive "$font.zip" -Force -DestinationPath "$font"
    $Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem "$font/$font" | ForEach-Object {
        # Install font
        Write-Host "Installing ($_.Name)"
        $Destination.CopyHere($_,0x10)
    }
    Remove-Item $font -Recurse
    Remove-Item "$font.zip"
}

Install-DelugiaCode 'delugia-complete'
Install-DelugiaCode 'delugia-mono-complete'
