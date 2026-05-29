# Deploy Garantia II miniapp to GitHub Pages (run by user).
# Creates public repo under your cached GitHub account, pushes files, enables Pages.
# Token is read from your local git credential cache and is NOT printed.

$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$repo = 'C:\Users\oleg_\garantia-ii-miniapp'
Set-Location $repo
New-Item -ItemType File -Path (Join-Path $repo '.nojekyll') -Force | Out-Null

# --- git init + commit ---
if (-not (Test-Path (Join-Path $repo '.git'))) { git init -q }
git config user.name  'vyati4'
git config user.email 'vyati4@users.noreply.github.com'
git add -A
git commit -q -m "Garantia II miniapp: test build (PWA + Telegram WebApp, demo data)"
git branch -M main
Write-Host ("git commit exit: " + $LASTEXITCODE)

# --- read token from credential cache (NOT printed) ---
$inp = "protocol=https`nhost=github.com`n`n"
$out = ($inp | git credential fill) 2>$null
$user  = (($out | Where-Object { $_ -like 'username=*' }) -replace '^username=','')
$token = (($out | Where-Object { $_ -like 'password=*' }) -replace '^password=','')
if ([string]::IsNullOrEmpty($token)) { Write-Host "ERROR: no GitHub token in credential cache. Run: git credential-manager github login"; exit 1 }
Write-Host ("github user: " + $user)

$headers = @{ Authorization = "Bearer $token"; 'User-Agent' = 'virtu-deploy'; Accept = 'application/vnd.github+json' }

# --- create public repo (ignore 'already exists') ---
$body = @{ name = 'garantia-ii-miniapp'; description = 'Garantia II - Telegram Mini App (test build)'; private = $false; has_issues = $false; has_wiki = $false; auto_init = $false } | ConvertTo-Json
try {
  $r = Invoke-RestMethod -Method Post -Uri 'https://api.github.com/user/repos' -Headers $headers -Body $body -ContentType 'application/json'
  Write-Host ("repo created: " + $r.full_name)
} catch {
  $code = $_.Exception.Response.StatusCode.value__
  Write-Host ("create repo HTTP " + $code + " (422 = already exists, ok)")
}

# --- push ---
$remoteToken = "https://$user`:$token@github.com/$user/garantia-ii-miniapp.git"
git remote remove origin 2>$null
git remote add origin $remoteToken
git push -u origin main
Write-Host ("git push exit: " + $LASTEXITCODE)
git remote set-url origin "https://github.com/$user/garantia-ii-miniapp.git"  # strip token from config

# --- enable GitHub Pages (branch main, root) ---
$pbody = @{ source = @{ branch = 'main'; path = '/' } } | ConvertTo-Json
try {
  $p = Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$user/garantia-ii-miniapp/pages" -Headers $headers -Body $pbody -ContentType 'application/json'
  Write-Host ("PAGES URL: " + $p.html_url)
} catch {
  $code = $_.Exception.Response.StatusCode.value__
  if ($code -eq 409) { Write-Host "pages: already enabled (409)" }
  else { Write-Host ("pages enable HTTP " + $code + " - enable manually: repo Settings > Pages > Branch: main / root") }
}

Write-Host ""
Write-Host ("REPO:  https://github.com/$user/garantia-ii-miniapp")
Write-Host ("SITE:  https://$user.github.io/garantia-ii-miniapp/   (live in ~1-2 min)")
