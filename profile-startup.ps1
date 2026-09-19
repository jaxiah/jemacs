[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $EmacsArgument
)

$configDirectory = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$emacsCommand = Get-Command runemacs.exe -ErrorAction SilentlyContinue
if (-not $emacsCommand) {
    Write-Error "找不到 runemacs.exe。请确认 Chocolatey 的 Emacs 已加入 PATH。"
    exit 1
}

$oldProfileFlag = $env:MY_EMACS_PROFILE_STARTUP
$oldProfileFile = $env:MY_EMACS_PROFILE_FILE
$profileFile = Join-Path $configDirectory 'data\startup-profile.el'

try {
    $env:MY_EMACS_PROFILE_STARTUP = '1'
    $env:MY_EMACS_PROFILE_FILE = $profileFile

    # Keep the same no-flash frame path as the normal launcher.  The profiler
    # report is opened after initialization and remains available in Emacs.
    & $emacsCommand.Source "--init-directory=$configDirectory" '--no-splash' '--geometry=160x48' '--iconic' @EmacsArgument
    $exitCode = $LASTEXITCODE
}
finally {
    if ($null -eq $oldProfileFlag) {
        Remove-Item Env:MY_EMACS_PROFILE_STARTUP -ErrorAction SilentlyContinue
    } else {
        $env:MY_EMACS_PROFILE_STARTUP = $oldProfileFlag
    }
    if ($null -eq $oldProfileFile) {
        Remove-Item Env:MY_EMACS_PROFILE_FILE -ErrorAction SilentlyContinue
    } else {
        $env:MY_EMACS_PROFILE_FILE = $oldProfileFile
    }
}

if ($exitCode -ne 0) {
    exit $exitCode
}

Write-Output "Startup profile: $profileFile"
