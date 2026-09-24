$ErrorActionPreference = 'Stop'

Write-Host 'This setup uses WSL2 for the Linux development environment.'
Write-Host 'The Linux setup script provides the shared toolchain and configuration.'

$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wsl) {
    Write-Host 'WSL is not installed. Installing it may change Windows features and require a reboot.'
    $answer = Read-Host 'Run the official WSL installation command now? [y/N]'
    if ($answer -notmatch '^(y|yes)$') {
        Write-Host 'Install WSL2 manually, reboot if requested, then rerun this script.'
        exit 1
    }
    wsl.exe --install
    Write-Host 'Complete the requested reboot and Linux distribution setup, then rerun setup.ps1.'
    exit 0
}

$wslDetails = (& wsl.exe --list --verbose 2>$null) -join "`n"
$wslDetails = $wslDetails -replace "`0", ''
if (-not $wslDetails -or $wslDetails -notmatch '(?m)^\s*\*?\s*\S+\s+\S+\s+2\s*$') {
    if ($wslDetails) {
        Write-Host 'WSL is installed, but no WSL2 distribution is available.'
        Write-Host 'Install a distribution with: wsl.exe --install -d Ubuntu'
        Write-Host 'Convert an existing distribution with: wsl.exe --set-version <name> 2'
        exit 1
    }
    Write-Host 'WSL is available but no Linux distribution is installed.'
    Write-Host 'Install Ubuntu with: wsl.exe --install -d Ubuntu'
    Write-Host 'If Windows requests a reboot, finish that step before rerunning this script.'
    exit 1
}

$repoWindows = (Resolve-Path (Join-Path $PSScriptRoot '.')).Path
$repoWsl = (& wsl.exe wslpath -a $repoWindows).Trim()
if (-not $repoWsl) { throw 'Could not map this repository path into WSL.' }
& wsl.exe --cd $repoWsl bash ./setup.sh @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
