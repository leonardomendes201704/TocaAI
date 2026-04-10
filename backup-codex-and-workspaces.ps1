[CmdletBinding()]
param(
  [string]$OutputDirectory = "$env:USERPROFILE\Desktop",
  [string]$CodexHome = "$env:USERPROFILE\.codex",
  [string]$WorkspacesRoot = "C:\Leonardo\Labs",
  [switch]$AllowCodexRunning,
  [int]$ProgressUpdateSeconds = 5
)

$ErrorActionPreference = 'Stop'

function Write-Step {
  param([string]$Message)
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Test-CommandExists {
  param([string]$CommandName)
  return [bool](Get-Command $CommandName -ErrorAction SilentlyContinue)
}

function Get-DirectorySizeBytes {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Directory not found: $Path"
  }

  return (Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum).Sum
}

function Format-Size {
  param([double]$Bytes)

  if ($Bytes -ge 1TB) { return '{0:N2} TB' -f ($Bytes / 1TB) }
  if ($Bytes -ge 1GB) { return '{0:N2} GB' -f ($Bytes / 1GB) }
  if ($Bytes -ge 1MB) { return '{0:N2} MB' -f ($Bytes / 1MB) }
  if ($Bytes -ge 1KB) { return '{0:N2} KB' -f ($Bytes / 1KB) }
  return '{0:N0} B' -f $Bytes
}

function Format-Duration {
  param([TimeSpan]$Duration)

  if ($Duration.TotalHours -ge 1) {
    return '{0:00}:{1:00}:{2:00}' -f [math]::Floor($Duration.TotalHours), $Duration.Minutes, $Duration.Seconds
  }

  return '{0:00}:{1:00}' -f $Duration.Minutes, $Duration.Seconds
}

function Join-ProcessArguments {
  param([string[]]$Arguments)

  $quotedArguments = foreach ($argument in $Arguments) {
    if ($argument -match '[\s"]') {
      '"' + ($argument -replace '"', '\"') + '"'
    } else {
      $argument
    }
  }

  return [string]::Join(' ', $quotedArguments)
}

if (-not (Test-Path -LiteralPath $CodexHome)) {
  throw "Nao encontrei a pasta do Codex em: $CodexHome"
}

if (-not (Test-Path -LiteralPath $WorkspacesRoot)) {
  throw "Nao encontrei a pasta de workspaces em: $WorkspacesRoot"
}

if (-not (Test-CommandExists -CommandName 'tar.exe')) {
  throw "Nao encontrei o tar.exe no PATH. Este script usa o tar nativo do Windows para gerar o ZIP."
}

if ($ProgressUpdateSeconds -lt 1) {
  throw "ProgressUpdateSeconds deve ser maior ou igual a 1."
}

$codexProcesses = Get-Process -ErrorAction SilentlyContinue |
  Where-Object { $_.ProcessName -match '^(Codex|codex)$' }

if ($codexProcesses -and -not $AllowCodexRunning) {
  $processList = ($codexProcesses | ForEach-Object { "$($_.ProcessName)#$($_.Id)" }) -join ', '
  throw "Feche completamente o Codex antes do backup. Processos detectados: $processList. Se quiser ignorar isso, rode com -AllowCodexRunning."
}

Write-Step "Preparando diretorio de saida"
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$zipPath = Join-Path $OutputDirectory "codex-full-backup_$timestamp.zip"

Write-Step "Calculando tamanho aproximado das fontes"
$codexSize = Get-DirectorySizeBytes -Path $CodexHome
$workspacesSize = Get-DirectorySizeBytes -Path $WorkspacesRoot
$totalSize = ($codexSize + $workspacesSize)

Write-Host "Codex home   : $CodexHome" -ForegroundColor Yellow
Write-Host "Tamanho      : $(Format-Size $codexSize)"
Write-Host "Workspaces   : $WorkspacesRoot" -ForegroundColor Yellow
Write-Host "Tamanho      : $(Format-Size $workspacesSize)"
Write-Host "Total aprox. : $(Format-Size $totalSize)" -ForegroundColor Yellow
Write-Host "Arquivo ZIP  : $zipPath" -ForegroundColor Green

Write-Step "Gerando ZIP unico sem exclusoes"
Write-Host "Feedback durante a compressao: tempo decorrido e tamanho atual do ZIP." -ForegroundColor DarkGray
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

$codexParent = Split-Path -Path $CodexHome -Parent
$codexLeaf = Split-Path -Path $CodexHome -Leaf
$workspacesParent = Split-Path -Path $WorkspacesRoot -Parent
$workspacesLeaf = Split-Path -Path $WorkspacesRoot -Leaf

$tarArguments = @(
  '-a'
  '-c'
  '-f'
  $zipPath
  '-C'
  $codexParent
  $codexLeaf
  '-C'
  $workspacesParent
  $workspacesLeaf
)

$backupStartedAt = Get-Date
$lastSizeDisplay = ""
$lastHeartbeatAt = Get-Date '2000-01-01'

$tarStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$tarStartInfo.FileName = 'tar.exe'
$tarStartInfo.Arguments = Join-ProcessArguments -Arguments $tarArguments
$tarStartInfo.UseShellExecute = $false
$tarStartInfo.RedirectStandardOutput = $false
$tarStartInfo.RedirectStandardError = $false
$tarStartInfo.CreateNoWindow = $true

$tarProcess = [System.Diagnostics.Process]::Start($tarStartInfo)

while (-not $tarProcess.HasExited) {
  $elapsed = (Get-Date) - $backupStartedAt
  $zipSizeBytes = if (Test-Path -LiteralPath $zipPath) {
    (Get-Item -LiteralPath $zipPath).Length
  } else {
    0
  }
  $zipSizeDisplay = Format-Size $zipSizeBytes
  $statusLine = "Tempo decorrido: $(Format-Duration $elapsed) | ZIP atual: $zipSizeDisplay"

  Write-Progress -Activity 'Gerando backup ZIP do Codex e workspaces' -Status $statusLine -CurrentOperation 'Compactando .codex e Labs'

  if ($zipSizeDisplay -ne $lastSizeDisplay -or (((Get-Date) - $lastHeartbeatAt).TotalSeconds -ge $ProgressUpdateSeconds)) {
    Write-Host "  $(Get-Date -Format 'HH:mm:ss') | $statusLine" -ForegroundColor DarkGray
    $lastHeartbeatAt = Get-Date
  }

  $lastSizeDisplay = $zipSizeDisplay
  Start-Sleep -Seconds $ProgressUpdateSeconds
  $tarProcess.Refresh()
}

Write-Progress -Activity 'Gerando backup ZIP do Codex e workspaces' -Completed

$tarProcess.WaitForExit()

if ($tarProcess.ExitCode -ne 0) {
  throw "O tar.exe terminou com erro. ExitCode=$($tarProcess.ExitCode)"
}

if (-not (Test-Path -LiteralPath $zipPath)) {
  throw "O ZIP nao foi gerado em: $zipPath"
}

$zipItem = Get-Item -LiteralPath $zipPath
$totalElapsed = (Get-Date) - $backupStartedAt

Write-Step "Backup concluido"
Write-Host "ZIP criado com sucesso: $($zipItem.FullName)" -ForegroundColor Green
Write-Host "Tamanho do ZIP       : $(Format-Size $zipItem.Length)" -ForegroundColor Green
Write-Host "Tempo total          : $(Format-Duration $totalElapsed)" -ForegroundColor Green

Write-Host ""
Write-Host "Conteudo incluido no ZIP:" -ForegroundColor Cyan
Write-Host "- $CodexHome"
Write-Host "- $WorkspacesRoot"

Write-Host ""
Write-Host "Proximo passo sugerido:" -ForegroundColor Cyan
Write-Host "Copie este ZIP para um disco externo ou nuvem antes de formatar a maquina."
