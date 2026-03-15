# Windows dotfiles setup script
# Copies all files from windows/dotfiles/ to the home directory ($HOME)
# Also copies programs/basic-vimrc.vim to the Vim and Neovim config locations
# Also installs fzf.vim and fzf plugins if git is available

$repoRoot    = Split-Path $PSScriptRoot -Parent
$dotfilesDir = Join-Path $PSScriptRoot "dotfiles"
$targetDir   = $HOME

# --- Dotfiles ---
Write-Host "Copying dotfiles from '$dotfilesDir' to '$targetDir'..."

Get-ChildItem -Path $dotfilesDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($dotfilesDir.Length + 1)
    $destination = Join-Path $targetDir $relativePath

    $destDir = Split-Path $destination -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    Copy-Item -Path $_.FullName -Destination $destination -Force
    Write-Host "  $relativePath"
}

# --- Vimrc ---
$vimrc = Join-Path $repoRoot "programs\basic-vimrc.vim"

$vimTargets = @(
    # Vim: $HOME\_vimrc
    (Join-Path $HOME ".vimrc"),
    # Neovim: $LOCALAPPDATA\nvim\init.vim
    (Join-Path $env:LOCALAPPDATA "nvim\init.vim")
)

Write-Host "Copying vimrc..."
foreach ($dest in $vimTargets) {
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -Path $vimrc -Destination $dest -Force
    Write-Host "  $dest"
}

# --- FZF plugins ---
if (Get-Command git -ErrorAction SilentlyContinue) {
    $fzfRepos = @(
        @{ Url = "https://github.com/junegunn/fzf";     Name = "fzf" },
        @{ Url = "https://github.com/junegunn/fzf.vim"; Name = "fzf.vim" }
    )

    $pluginDirs = @(
        (Join-Path $HOME "vimfiles\pack\plugins\start"),
        (Join-Path $env:LOCALAPPDATA "nvim\pack\plugins\start")
    )

    Write-Host "Installing fzf plugins..."
    foreach ($pluginDir in $pluginDirs) {
        if (-not (Test-Path $pluginDir)) {
            New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
        }
        foreach ($repo in $fzfRepos) {
            $dest = Join-Path $pluginDir $repo.Name
            if (Test-Path $dest) {
                Write-Host "  $($repo.Name) already exists in $pluginDir, skipping"
            } else {
                Write-Host "  Cloning $($repo.Name) into $pluginDir..."
                git clone --depth 1 $repo.Url $dest
            }
        }
    }
} else {
    Write-Host "git not found, skipping fzf plugin installation"
}

Write-Host "Done."
