[CmdletBinding()]
param(
    [ValidateRange(1, 20)]
    [int] $Runs = 5
)

$configDirectory = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$emacsCommand = Get-Command emacs.exe -ErrorAction SilentlyContinue
if (-not $emacsCommand) {
    Write-Error "找不到 emacs.exe。请确认 Chocolatey 的 Emacs 已加入 PATH。"
    exit 1
}

# Batch mode deliberately excludes frame creation and server startup.  It
# gives a stable number for comparing configuration changes on the same PC.
$configForLisp = $configDirectory.Replace('\', '/')
$setConfigExpression = '(setq user-emacs-directory "' + $configForLisp + '/")'
$earlyInit = Join-Path $configDirectory 'early-init.el'
$initFile = Join-Path $configDirectory 'init.el'
$arguments = @(
    '--batch', '-Q',
    '--eval', $setConfigExpression,
    '--load', $earlyInit,
    '--load', $initFile,
    '--eval', '(kill-emacs)'
)

$results = foreach ($run in 1..$Runs) {
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $output = & $emacsCommand.Source @arguments 2>&1
    $exitCode = $LASTEXITCODE
    $timer.Stop()

    if ($exitCode -ne 0) {
        Write-Error ("第 {0} 次启动测试失败（退出码 {1}）：`n{2}" -f
            $run, $exitCode, ($output -join "`n"))
        exit $exitCode
    }

    [pscustomobject]@{
        Run = $run
        Milliseconds = [math]::Round($timer.Elapsed.TotalMilliseconds, 1)
    }
}

$values = @($results | ForEach-Object { [double]$_.Milliseconds })
Write-Output "jemacs batch startup benchmark"
Write-Output ("Configuration: {0}" -f $configDirectory)
Write-Output ("Runs:          {0}" -f $Runs)
$results | Format-Table -AutoSize
Write-Output ("Min:           {0:N1} ms" -f (($values | Measure-Object -Minimum).Minimum))
Write-Output ("Average:       {0:N1} ms" -f (($values | Measure-Object -Average).Average))
Write-Output ("Max:           {0:N1} ms" -f (($values | Measure-Object -Maximum).Maximum))
