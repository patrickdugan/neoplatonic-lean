# Installs the pinned Windows toolchain inside this project only.
# Requires Git, Python, curl.exe, and tar.exe on PATH.
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$toolRoot = Join-Path $PSScriptRoot '.toolchain'
$archivePath = Join-Path $toolRoot 'lean-4.24.0-windows.zip'
$binPath = Join-Path $toolRoot 'lean-4.24.0-windows\bin'
$expectedHash = 'C2FCF1CBA1089E526E184DE2A6F6763A6E15596A2991F096DFACD4A6E3CE2CDD'
New-Item -ItemType Directory -Force -Path $toolRoot | Out-Null
if (-not (Test-Path -LiteralPath (Join-Path $binPath 'lean.exe'))) {
    if (-not (Test-Path -LiteralPath $archivePath)) {
        curl.exe -fL --retry 2 -o $archivePath 'https://github.com/leanprover/lean4/releases/download/v4.24.0/lean-4.24.0-windows.zip'
        if ($LASTEXITCODE) { throw 'Lean download failed' }
    }
    if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash -ne $expectedHash) {
        throw 'Lean archive SHA256 mismatch'
    }
    tar.exe -xf $archivePath -C $toolRoot
    if ($LASTEXITCODE) { throw 'Lean extraction failed' }
}
$env:PATH = $binPath + ';' + $env:PATH
$env:MATHLIB_CACHE_DIR = Join-Path $toolRoot 'mathlib-cache'
lake exe cache get Mathlib.Logic.Relation Mathlib.Data.Int.Basic Mathlib.Tactic.Basic Mathlib.NumberTheory.LSeries.RiemannZeta Mathlib.Order.CompleteLattice.Defs Mathlib.Topology.Compactness.Compact Mathlib.CategoryTheory.Category.Preorder Mathlib.CategoryTheory.Limits.Shapes.IsTerminal
if ($LASTEXITCODE) { throw 'Mathlib cache retrieval failed' }
python verify.py
if ($LASTEXITCODE) { throw 'Verification failed' }
