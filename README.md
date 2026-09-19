# jemacs

A Windows-friendly, vanilla-style Emacs configuration. It keeps packages,
state, backups, and native-compilation caches inside the configuration
directory instead of using the default Emacs directory.

## Requirements

- Emacs 29.1 or newer; the Chocolatey build is supported.
- Git and ripgrep are recommended.
- C/C++ support expects `clangd` and optionally `clang-format`.
- Python support works with Eglot-compatible language servers and optionally
  `black` and `debugpy`.

Package downloads use the local proxy `localhost:4878` by default. Set
`my-package-proxy` to `nil` in `custom.el` to use a direct connection.

## Starting Emacs

Run or double-click:

```bat
run-emacs.cmd
```

The launcher uses `runemacs.exe`, selects this directory with
`--init-directory`, and starts an iconified 160-by-48 frame. The configuration
reveals and centers the frame after initialization, avoiding the temporary raw
Emacs window and a console window.

An equivalent manual command is:

```bat
runemacs.exe --init-directory="C:\path\to\jemacs" --no-splash --geometry=160x48 --iconic
```

## Editing experience

- Standard Emacs keybindings remain the default; `M-z` toggles Evil on demand.
- Vertico, Orderless, Consult, Marginalia, Embark, Corfu, and Cape provide
  completion and navigation.
- Projectile, Magit, Ace Window, Avy, Expand Region, Which-Key, and Beacon are
  available without replacing normal Emacs workflows.
- `C-s` starts isearch with the active region when one exists.
- `C-u C-x C-f` opens a file literally.
- `C-x C-r` opens recent files, and `C-x C-b` uses Ibuffer.
- C/C++ and Python use Eglot. Tree-sitter modes are selected automatically when
  their grammars are installed.
- Dape and formatting support are available as optional programming tools.
- Exiting, saving, and modified-buffer prompts follow normal Emacs behavior.

Useful commands:

- `M-x my/open-config` opens the main init file.
- `M-x my/package-report` reports package and external-tool availability.
- `M-x my/install-optional-packages` installs optional development packages.
- `M-x my/enable-copilot` installs and enables Copilot on demand.

## Startup diagnostics

Run a repeatable batch benchmark:

```powershell
.\benchmark-startup.ps1 -Runs 5
```

Emacs also reports its own initialization time in the echo area. Use
`M-x emacs-init-time` to display it again.

To collect a built-in CPU profiler report for one launch:

```powershell
.\profile-startup.ps1
```

The profiler report opens after startup and is saved under `data/`. Reopen a
saved profile with `M-x profiler-find-profile`.

## Troubleshooting

Start Emacs with init debugging enabled:

```bat
emacs.exe --debug-init --init-directory="C:\path\to\jemacs"
```

All generated state is kept in ignored directories such as `data/`, `cache/`,
and `packages/`.
