param(
    [string]$Message = "Update net rates workbook"
)

$ErrorActionPreference = "Stop"

$excelFile = "Net rates Webapp.xlsx"
$targetBranch = "main"

try {
    git rev-parse --is-inside-work-tree | Out-Null
} catch {
    Write-Error "This folder is not a Git repository."
    exit 1
}

$currentBranch = (git branch --show-current).Trim()
if ($currentBranch -ne $targetBranch) {
    Write-Error "You are on branch '$currentBranch'. Switch to '$targetBranch' before publishing."
    exit 1
}

if (-not (Test-Path $excelFile)) {
    Write-Error "Cannot find '$excelFile' in the repository root."
    exit 1
}

$porcelain = git status --porcelain
if (-not $porcelain) {
    Write-Host "No changes found to publish."
    exit 0
}

# Only publish the Excel workbook to reduce accidental deployments.
git add -- "$excelFile"

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host "Workbook unchanged. Nothing was staged or published."
    exit 0
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMessage = "$Message ($timestamp)"

git commit -m "$commitMessage"
git push origin $targetBranch

Write-Host "Publish complete. Streamlit Cloud will redeploy from GitHub."
