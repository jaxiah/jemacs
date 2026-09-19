@echo off
where runemacs.exe >nul 2>&1
if errorlevel 1 goto missing_emacs

rem %~dp0 includes a trailing backslash; append a dot so the quote is parsed correctly.
rem Keep the initial frame iconified until the config has applied its theme,
rem font and centered position; this avoids a raw Emacs window flash.
runemacs.exe --init-directory="%~dp0." --no-splash --geometry=160x48 --iconic %*
exit /b %errorlevel%

:missing_emacs
echo 找不到 runemacs.exe。请确认 Chocolatey 的 Emacs 已加入 PATH。
exit /b 1
